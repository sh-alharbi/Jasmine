//
//  String+Section.swift
//  Jasmine
//
//  Created by lamess on 15/06/1447 AH.
//

import Foundation

extension String {

    func section(_ title: String) -> String {
        let parts = self.components(separatedBy: "###")

        for part in parts {
            if part.lowercased().contains(title.lowercased()) {
                return part
                    .replacingOccurrences(of: title, with: "")
                    .replacingOccurrences(of: ":", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        return "Not available"
    }
    
    func cleanMarkdown() -> String {
        return self
            .replacingOccurrences(of: "**", with: "")
            .replacingOccurrences(of: "###", with: "")
          //  .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "1)", with: "")
            .replacingOccurrences(of: "2)", with: "")
            .replacingOccurrences(of: "3)", with: "")
            .replacingOccurrences(of: "Short Explanation", with: "")
            .replacingOccurrences(of: "General Prevention & Lifestyle", with: "")
            .replacingOccurrences(of: "Trusted Medical", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

        func cleanPopupText() -> String {
            return self
                .replacingOccurrences(of: "**", with: "")
                .replacingOccurrences(of: "-", with: "")
                .replacingOccurrences(
                    of: #"^[0-9]+\)"#,
                    with: "",
                    options: .regularExpression
                )
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }



