//
//  ProfileViewModel.swift
//  Jasmine
//

import Foundation
import Supabase
import UserNotifications
import SwiftUI
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published var fullName: String = ""
    @Published var email: String = ""
    
    @Published var isRewardOn: Bool = false
    @Published var isNotificationOn: Bool = false
    
    private struct UserRow: Decodable {
        let fname: String
        let lname: String
        let email: String
        let rewardpreference: Bool
        let notificationpreference: Bool
    }
    
    func loadUser(userId: UUID) async {
        do {
            let row: UserRow = try await Supa.client
                .from("users")
                .select("fname,lname,email,rewardpreference,notificationpreference")
                .eq("userid", value: userId)
                .single()
                .execute()
                .value
            
            fullName = "\(row.fname) \(row.lname)"
            email = row.email
            isRewardOn = row.rewardpreference
            isNotificationOn = row.notificationpreference
            
            print("✅ user loaded from users table")
        } catch {
            print("loadUser error FULL:", error)
            print("loadUser error:", error.localizedDescription)
        }

    }
    
    func updateName(userId: UUID, fullName: String) async {
        let trimmed = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let parts = trimmed.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        let fname = String(parts.first ?? Substring(trimmed))
        let lname = parts.count > 1 ? String(parts[1]) : ""
        
        do {
            try await Supa.client
                .from("users")
                .update([
                    "fname": fname,
                    "lname": lname
                ])
                .eq("userid", value: userId)
                .execute()
            
            self.fullName = trimmed
            print("✅ Name updated in users table")
        } catch {
            print("updateName error:", error.localizedDescription)
        }
    }
    
    func updateRewardPreference(userId: UUID, isOn: Bool) async  {
        do {
            try await Supa.client
                .from("users")
                .update(["rewardpreference": isOn])
                .eq("userid", value: userId.uuidString) 
                .execute()

            print("✅ rewardpreference updated:", isOn)
        } catch {
            print("updateRewardPreference error:", error.localizedDescription)
        }
    }

    
    func updateNotificationPreference(userId: UUID, isOn: Bool) async {
        do {
            try await Supa.client
                .from("users")
                .update(["notificationpreference": isOn])
                .eq("userid", value: userId.uuidString)
                .execute()

            print("✅ notificationpreference updated:", isOn)
        } catch {
            print("updateNotificationPreference error:", error.localizedDescription)
        }
    }

    }

