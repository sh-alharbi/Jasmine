//
//  ActivityViewModel.swift
//  Jasmine
//
//  Created by lamess on 09/06/1447 AH.
import Foundation
import Supabase
import Combine

@MainActor
class ActivityViewModel: ObservableObject {

    @Published var history: [UserHistory] = []
    @Published var loading = false
    @Published var selectedEntry: UserHistory?
    @Published var showPopUp = false
    // ✅ ترقيم الحالات بعد الترتيب الصحيح
    func numberedCondition(for item: UserHistory) -> String {

        let sameConditions = history.filter {
            $0.condition.lowercased() == item.condition.lowercased()
        }

        // لو حالة وحدة فقط → بدون رقم
        if sameConditions.count == 1 {
            return item.condition.capitalized
        }

        // ترتيب من الأقدم إلى الأحدث للترقيم فقط
        let sorted = sameConditions.sorted {
            $0.date < $1.date
        }

        if let index = sorted.firstIndex(where: { $0.id == item.id }) {
            let number = index + 1

            // ✅ لا نعرض 1
            if number == 1 {
                return item.condition.capitalized
            } else {
                return "\(item.condition.capitalized) \(number)"
            }
        }

        return item.condition.capitalized
    }



    // ✅ تحميل التاريخ مع ترتيب زمني صحيح فعليًا
    func loadHistory(userId: String) async {
        loading = true
        defer { loading = false }

        do {
            let imageResponse = try await Supa.client
                .from("skin_images")
                .select()
                .eq("userid", value: userId)
                .order("uploaddate", ascending: false) // ✅ الترتيب من الأحدث للأقدم حسب الوقت
                .execute()


            let images = try JSONDecoder().decode([SkinImageRow].self, from: imageResponse.data)

            var combined: [UserHistory] = []

            for img in images {
                let analysisResponse = try await Supa.client
                    .from("analysis")
                    .select()
                    .eq("imageid", value: img.imageid)
                    .execute()

                let analysisList = try JSONDecoder().decode([AnalysisRow].self, from: analysisResponse.data)

                guard let analysis = analysisList.first else { continue }

                let entry = UserHistory(
                    id: img.imageid,
                    condition: analysis.conditionlabel,
                    date: img.uploaddate,
                    imagePath: img.storagepath,
                    recommendation: analysis.recommendation
                )

                combined.append(entry)
            }

            self.history = combined  // ✅ يصل مرتب جاهز
        } catch {
            print("❌ loadHistory error:", error.localizedDescription)
        }
    }




    // ✅ فتح البوب
    func openDetails(_ item: UserHistory) {
        selectedEntry = item
        showPopUp = true
    }

    // ✅ إغلاق البوب
    func closePopUp() {
        selectedEntry = nil
        showPopUp = false
    }
}
