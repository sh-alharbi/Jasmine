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
class ContentViewModel: ObservableObject {

    // MARK: - UI State
    @Published var selectedImage: UIImage? = nil
    @Published var isLoading = false
    @Published var result: PredictResponse? = nil
    @Published var step: Int = 1
    @Published var errorMsg: String? = nil
    @Published var saveToHistory = false
    @Published var isSaving = false
    @Published var infoMsg: String? = nil
    @Published var goToActivity = false

    // MARK: - Analysis
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

    // MARK: - Save To History
    func saveToHistory(userId: String) async {

        guard saveToHistory else { return }
        guard let img = selectedImage else { return }
        guard let result else {
            infoMsg = "No analysis result found."
            return
        }

        isSaving = true
        defer { isSaving = false }

        do {
            let imageID = UUID().uuidString
            let fileName = "\(imageID).jpg"

            guard let data = img.jpegData(compressionQuality: 0.9) else {
                infoMsg = "Failed to encode image."
                return
            }

            // ✅ رفع الصورة
            try await Supa.client.storage
                .from("skin-images")
                .upload(
                    path: fileName,
                    file: data,
                    options: FileOptions(contentType: "image/jpeg", upsert: true)
                )

            // ✅ حفظ في skin_images
            struct SkinImageRow: Encodable {
                let imageid: String
                let userid: String
                let uploaddate: String
                let storagepath: String
            }

            let imageRow = SkinImageRow(
                imageid: imageID,
                userid: userId,
                uploaddate: isoDateString(Date()),
                storagepath: fileName
            )

            try await Supa.client
                .from("skin_images")
                .insert(imageRow)
                .execute()

            // ✅ حفظ في analysis
            struct AnalysisRow: Encodable {
                let analysisid: String
                let imageid: String
                let conditionlabel: String
                let recommendation: String
            }

            let analysisRow = AnalysisRow(
                analysisid: UUID().uuidString,
                imageid: imageID,
                conditionlabel: result.top1.label,
                recommendation: result.chatgpt_explanation ?? "No recommendation"
            )

            try await Supa.client
                .from("analysis")
                .insert(analysisRow)
                .execute()

            infoMsg = "Saved to history ✅"

        } catch {
            infoMsg = "Save failed."
            print("❌ Save error:", error.localizedDescription)
        }
    }

    // MARK: - Helpers
    private func isoDateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}
