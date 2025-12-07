//
//  UserHistory.swift
//  Jasmine
//
//  Created by lamess on 14/06/1447 AH.
//
import Foundation

struct UserHistory: Identifiable {
    let id: String
    let condition: String
    let date: String
    let imagePath: String
    let recommendation: String

    var formattedDate: String { date }

    var isClear: Bool {
        condition.lowercased() == "normal" || condition.lowercased() == "clear"
    }

    // ✅ تقسيم المحتوى
    var explanation: String {
        extractSection(title: "Explanation")
    }

    var tips: String {
        extractSection(title: "Tips")
    }

    var sources: String {
        extractSection(title: "Sources")
    }

    private func extractSection(title: String) -> String {
        let parts = recommendation.components(separatedBy: "###")
        for part in parts {
            if part.lowercased().contains(title.lowercased()) {
                return part
                    .replacingOccurrences(of: title, with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return "Not available"
    }
}

