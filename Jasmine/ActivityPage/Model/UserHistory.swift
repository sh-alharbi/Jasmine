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
    let date: String      // "2025-10-24"
    let imagePath: String?
}

extension UserHistory {

    /// returns true when condition is "all clear"
    var isClear: Bool {
        condition.lowercased() == "all clear"
    }

    /// Converts yyyy-MM-dd → October 24, 2025
    var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"

        if let d = f.date(from: date) {
            f.dateFormat = "MMMM dd, yyyy"
            return f.string(from: d)
        }

        return date   // fallback
    }
}
