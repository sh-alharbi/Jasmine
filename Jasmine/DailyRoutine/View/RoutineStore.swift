//
//  RoutineStore.swift
//  Jasmine
//
//  Created by Shahad Alharbi on 12/13/25.
//

import Foundation
import Combine
import Supabase

@MainActor
final class RoutineStore: ObservableObject {

    @Published var routines: [Routine] = []
    @Published var isRewardEnabled: Bool = false
    @Published var totalPoints: Int = 0

    func routines(for date: Date) -> [Routine] {
        routines.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    func isDayCompleted(_ date: Date) -> Bool {
        let dayRoutines = routines(for: date)
        return !dayRoutines.isEmpty && dayRoutines.allSatisfy { $0.isDone }
    }

    func add(_ routine: Routine) { routines.append(routine) }

    func update(_ updated: Routine) {
        if let index = routines.firstIndex(where: { $0.id == updated.id }) {
            routines[index] = updated
        }
    }

    func delete(_ id: UUID) {
        if let index = routines.firstIndex(where: { $0.id == id }) {
            routines.remove(at: index)
        }
    }

    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        f.dateFormat = "HH:mm:ss"
        return f.string(from: date)
    }

    private func formatDateOnly(_ date: Date) -> String {
        let d = Calendar.current.startOfDay(for: date)
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: d)
    }

    private struct DailyRoutineUpsert: Encodable {
        let routineid: UUID
        let userid: UUID
        let routinename: String
        let isdone: Bool
        let time: String
        let routinetype: String
        let date: String
    }

    private struct RewardRow: Decodable {
        let rewardid: UUID?
        let userid: UUID
        let points: Int
    }

    private struct RewardUpsert: Encodable {
        let userid: UUID
        let points: Int
    }

    func loadRewardPoints() async {
        guard let session = Supa.client.auth.currentSession else {
            print("⚠️ No Supabase session (loadRewardPoints)")
            return
        }

        let uid = session.user.id

        do {
            let res = try await Supa.client
                .from("reward_system")
                .select()
                .eq("userid", value: uid.uuidString)
                .limit(1)
                .execute()

            let rows = try JSONDecoder().decode([RewardRow].self, from: res.data)

            if let row = rows.first {
                self.totalPoints = row.points
            } else {
                self.totalPoints = 0
            }

            print("✅ Loaded points:", self.totalPoints)
        } catch {
            print("❌ loadRewardPoints failed:", error.localizedDescription)
        }
    }

    func addPoints(_ delta: Int) async {
        guard let session = Supa.client.auth.currentSession else {
            print("⚠️ No Supabase session (addPoints)")
            return
        }

        let uid = session.user.id

        do {
            let res = try await Supa.client
                .from("reward_system")
                .select()
                .eq("userid", value: uid.uuidString)
                .limit(1)
                .execute()

            let rows = try JSONDecoder().decode([RewardRow].self, from: res.data)
            let current = rows.first?.points ?? 0
            let newPoints = current + delta

            try await Supa.client
                .from("reward_system")
                .upsert(RewardUpsert(userid: uid, points: newPoints), onConflict: "userid")
                .execute()

            self.totalPoints = newPoints
            print("✅ Points updated in DB:", newPoints)
        } catch {
            print("❌ addPoints failed:", error.localizedDescription)
        }
    }


    func toggleDone(id: UUID) {
        guard let index = routines.firstIndex(where: { $0.id == id }) else { return }

        routines[index].isDone.toggle()
        let r = routines[index]
        let isDoneNow = r.isDone

        guard isDoneNow == true else { return }

        Task {
            guard let session = Supa.client.auth.currentSession else {
                print("⚠️ No Supabase session")
                return
            }

            let uid = session.user.id

            let row = DailyRoutineUpsert(
                routineid: r.id,
                userid: uid,
                routinename: r.routineName,
                isdone: true,
                time: formatTime(r.time),
                routinetype: r.type.rawValue,
                date: formatDateOnly(r.date)
            )

            do {
                try await Supa.client
                    .from("daily_routine")
                    .upsert(row, onConflict: "userid,date,routinename,routinetype")
                    .execute()

                print("✅ Saved to DB:", r.routineName)

                guard self.isRewardEnabled else { return }
                await self.addPoints(5)

            } catch {
                print("❌ upsert failed:", error.localizedDescription)
            }
        }
    }
}
