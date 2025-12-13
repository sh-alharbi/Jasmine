//
//  NotificationManager.swift
//  Jasmine
//
//  Created by Shahad Alharbi on 12/7/25.
//

import Foundation
import UserNotifications
import Supabase   

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestPermission() async -> Bool {
        do {
            let center = UNUserNotificationCenter.current()
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("🔴 Notification permission error:", error.localizedDescription)
            return false
        }
    }

    func scheduleRoutineReminder() {
        let center = UNUserNotificationCenter.current()

        center.removePendingNotificationRequests(withIdentifiers: ["routine_reminder_12h"])

        let content = UNMutableNotificationContent()
        content.title = "Don’t forget your skincare routine !"
        content.body  = "Take a moment to complete your skin routine today."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 12 * 60 * 60,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "routine_reminder_12h",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("🔴 Failed to schedule reminder:", error.localizedDescription)
            } else {
                print("✅ 12h routine reminder scheduled")
                Task {
                    await self.logNotificationToSupabase(message: content.body)
                }
            }
        }
    }

    func cancelRoutineReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["routine_reminder_12h"])
        print("⚪️ Routine reminder cancelled")
    }


    private func logNotificationToSupabase(message: String) async {
        guard let session = Supa.client.auth.currentSession else {
            print("⚠️ No Supabase session – skip logging notification")
            return
        }

        struct NotificationRow: Encodable {
            let notificationid: UUID
            let userid: UUID
            let message: String
            let date: Date
        }


        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())

        let row = NotificationRow(
            notificationid: UUID(),
            userid: session.user.id,
            message: message,
            date: Date()
        )

        do {
            try await Supa.client
                .from("notifications")
                .insert(row)
                .execute()

            print("✅ notification logged in Supabase")
        } catch {
            print("❌ failed to log notification:", error)
        }
    }
}
