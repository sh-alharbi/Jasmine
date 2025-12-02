//
//  UserProfile.swift
//  Jasmine
//
//  Created by Shahad Alharbi on 12/2/25.
//

import Foundation

struct UserProfile: Identifiable {
    let id: String          // Supabase user id (userid)
    var firstName: String
    var lastName: String
    var email: String
    var rewardPreference: Bool

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
