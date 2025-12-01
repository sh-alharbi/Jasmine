//
//  ActivityViewModel.swift
//  Jasmine
//
//  Created by lamess on 09/06/1447 AH.
//
import Foundation
import Supabase
import SwiftUI
import Combine
@MainActor
class ActivityViewModel: ObservableObject {

    @Published var history: [AnalysisHistoryJSON] = []
    @Published var selectedEntry: AnalysisHistoryJSON? = nil
    @Published var showPopUp = false
    @Published var loading = false

    // MARK: - LOAD HISTORY FROM SUPABASE
    func loadHistoryFor(userId: UUID) async {
        loading = true
        defer { loading = false }

        do {
            // 1) Fetch rows as [SkinAssessmentHistory]
            let rows: [SkinAssessmentHistory] = try await Supa.client
                .from("skin_assessment_history")
                .select()
                .eq("userid", value: userId.uuidString)
                .order("date", ascending: false)
                .execute()
                .value

            // 2) Convert JSON text in historyData → AnalysisHistoryJSON
            var converted: [AnalysisHistoryJSON] = []

            for row in rows {
                if let data = row.historyData.data(using: String.Encoding.utf8) {
                    if let parsed = try? JSONDecoder().decode(AnalysisHistoryJSON.self, from: data) {
                        converted.append(parsed)
                    }
                }
            }

            self.history = converted

        } catch {
            print("❌ Error loading history:", error.localizedDescription)
        }
    }

    func openDetails(_ item: AnalysisHistoryJSON) {
        selectedEntry = item
        showPopUp = true
    }

    func closePopUp() {
        showPopUp = false
    }
}
