//
//  ContentViewModel.swift
//  Jasmine
//
//  Created by lamess on 15/06/1447 AH.
//

import Foundation
import UIKit
import Supabase
import Combine

@MainActor
class AnalysisViewModel: ObservableObject {

    @Published var selectedImage: UIImage? = nil
    @Published var isLoading = false
    @Published var result: PredictResponse? = nil
    @Published var step: Int = 1
    @Published var errorMsg: String? = nil
    @Published var saveToHistory = false
    @Published var isSaving = false
    @Published var infoMsg: String? = nil
    @Published var goToActivity = false
    



    func analyze() async {
        guard let selectedImage else {
            errorMsg = "Please select a photo first."
            return
        }

        isLoading = true
        errorMsg = nil
        defer { isLoading = false }

        do {
            let res = try await SkinAPIService.shared.predict(image: selectedImage, topk: 1)
            self.result = res
        } catch {
            self.result = nil
            self.errorMsg = error.localizedDescription
        }
    }


    func saveToHistory(userId: UUID) async {

        guard let selectedImage else {
            infoMsg = "No image found."
            return
        }

        guard let result else {
            infoMsg = "No analysis result found."
            return
        }

        isSaving = true
        defer { isSaving = false }

        do {
            let (imageID, path) = try await JasmineService.uploadSkinImage(selectedImage, userID: userId)

            try await JasmineService.saveAnalysis(
                imageID: imageID,
                label: result.top1.label,
                recommendation: result.chatgpt_explanation ?? "No recommendation"
            )

            struct HistoryRow: Encodable {
                let historyid: UUID
                let userid: UUID
                let historydata: String
                let date: String
            }

            let historyText = """
            Condition: \(result.top1.label)
            ImagePath: \(path)
            Recommendation:
            \(result.chatgpt_explanation ?? "No recommendation")
            """

            let historyRow = HistoryRow(
                historyid: UUID(),
                userid: userId,
                historydata: historyText,
                date: isoDateString(Date()) 
            )

            try await Supa.client
                .from("skin_analysis_history")
                .insert(historyRow)
                .execute()

            infoMsg = "Saved to history ✅"
            goToActivity = true

        } catch {
            infoMsg = error.localizedDescription
            print("saveToHistory error:", error)
        }
    }

    



    private func isoDateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
    
    @MainActor
func resetAll() {
    self.step = 1
    self.selectedImage = nil
    self.result = nil
    self.errorMsg = nil
    self.isLoading = false
    self.goToActivity = false
    self.saveToHistory = false
    
    
}
    }



