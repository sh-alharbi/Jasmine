//
//  ActivityModel.swift
//  Jasmine
//
//  Created by lamess on 09/06/1447 AH.
//
import Foundation

// MARK: - Model received from Supabase

struct SkinAssessmentHistory: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let historyData: String       // JSON string
    let date: String              // yyyy-MM-dd
}

// MARK: - JSON stored during analysis

struct AnalysisHistoryJSON: Codable {
    let label: String
    let confidence: Double
    let explanation: String       // full chatgpt_explanation text
    let imagePath: String?
    let scanDate: String
}

// MARK: - Parsed Sections

struct ParsedSections {
    let explanation: String
    let tips: [String]
    let sources: [String]
}

// MARK: - Parser

final class ExplanationParser {

    static func parse(_ text: String) -> ParsedSections {
        var explanation = ""
        var tips: [String] = []
        var sources: [String] = []

        // Split by ###
        let rawSections = text.components(separatedBy: "###")

        for section in rawSections {
            let t = section.trimmingCharacters(in: .whitespacesAndNewlines)

            // 1) Explanation
            if t.starts(with: "1)") || t.lowercased().contains("explanation") {
                explanation = cleanSection(t)
            }
            // 2) Tips
            else if t.starts(with: "2)") || t.lowercased().contains("tips") {
                let lines = t.components(separatedBy: "\n")
                tips = lines
                    .filter { $0.starts(with: "-") }
                    .map { cleanBullet($0) }
            }
            // 3) Sources
            else if t.starts(with: "3)") || t.lowercased().contains("source") {
                let lines = t.components(separatedBy: "\n")
                sources = lines
                    .filter { $0.starts(with: "-") }
                    .map { cleanBullet($0) }
            }
        }

        return ParsedSections(
            explanation: explanation,
            tips: tips,
            sources: sources
        )
    }

    private static func cleanSection(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "1)", with: "")
            .replacingOccurrences(of: "Short Explanation of", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func cleanBullet(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "-", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
