//
//  ActivityViewModel.swift
//  Jasmine
//
//  Created by lamess on 09/06/1447 AH.
//
import Foundation
import SwiftUI
import Supabase
import Combine

@MainActor
class ActivityViewModel: ObservableObject {

    @Published var history: [UserHistory] = []
    @Published var loading = false
    @Published var selectedEntry: UserHistory?
    @Published var showPopUp = false

//    func loadHistory(userId: String) async {
//        loading = true
//        defer { loading = false }
//
//        do {
//            // 1) Fetch all images of this user
//            let imageResponse = try await Supa.client
//                .from("skin_images")
//                .select("""
//                    imageid,
//                    userid,
//                    uploaddate,
//                    storagepath
//                """)
//                .eq("userid", value: userId)
//                .order("uploaddate", ascending: false)
//                .execute()
//
//            // Decode rows
//            let images: [SkinImageRow] = try JSONDecoder().decode([SkinImageRow].self, from: imageResponse.data)
//
//            var combined: [UserHistory] = []
//
//            // 2) For each image, fetch its analysis
//            for img in images {
//
//                let analysisResponse = try await Supa.client
//                    .from("analysis")
//                    .select("""
//                        analysisid,
//                        imageid,
//                        conditionlabel,
//                        recommendation
//                    """)
//                    .eq("imageid", value: img.imageid)
//                    .single()     // كل صورة لها تحليل واحد فقط
//                    .execute()
//
//                let analysis = try JSONDecoder().decode(AnalysisRow.self, from: analysisResponse.data)
//
//                let entry = UserHistory(
//                    id: img.imageid,
//                    condition: analysis.conditionlabel,
//                    date: img.uploaddate,
//                    imagePath: img.storagepath
//                )
//
//                combined.append(entry)
//            }
//
//            self.history = combined
//
//        } catch {
//            print("❌ ERROR Loading History:", error.localizedDescription)
//        }
//    }

    func loadHistory(userId: String) async {
        loading = true
        defer { loading = false }

        print("🟢 loadHistory called with userId:", userId)

        do {
            let imageResponse = try await Supa.client
                .from("skin_images")
                .select("""
                    imageid,
                    userid,
                    uploaddate,
                    storagepath
                """)
                .eq("userid", value: userId)
                .order("uploaddate", ascending: false)
                .execute()

            print("📸 Raw image response:", String(data: imageResponse.data, encoding: .utf8) ?? "nil")

            let images: [SkinImageRow] = try JSONDecoder().decode([SkinImageRow].self, from: imageResponse.data)

            print("✅ Images count:", images.count)

            var combined: [UserHistory] = []

            for img in images {
                print("➡️ Fetching analysis for image:", img.imageid)

                let analysisResponse = try await Supa.client
                    .from("analysis")
                    .select("""
                        analysisid,
                        imageid,
                        conditionlabel,
                        recommendation
                    """)
                    .eq("imageid", value: img.imageid)
                    .single()
                    .execute()

                print("🧪 Raw analysis:", String(data: analysisResponse.data, encoding: .utf8) ?? "nil")

                let analysis = try JSONDecoder().decode(AnalysisRow.self, from: analysisResponse.data)

                let entry = UserHistory(
                    id: img.imageid,
                    condition: analysis.conditionlabel,
                    date: img.uploaddate,
                    imagePath: img.storagepath
                )

                combined.append(entry)
            }

            self.history = combined
            print("✅ Final history count:", combined.count)

        } catch {
            print("❌ ERROR Loading History FULL:", error)
        }
    }

    func openDetails(_ item: UserHistory) {
        selectedEntry = item
        showPopUp = true
    }

    func closePopUp() {
        selectedEntry = nil
        showPopUp = false
    }
}

