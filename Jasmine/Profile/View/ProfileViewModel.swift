//
//  ProfileViewModel.swift
//  Jasmine
//
//  Created by Shahad Alharbi on 12/2/25.
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
    @Published var notificationsEnabled: Bool = false

    private struct UserRow: Decodable {
        let fname: String
        let lname: String
        let email: String
    }
    
    func checkNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        self.notificationsEnabled = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
    }

    func loadUser(userId: String) async {
        do {
            let row: UserRow = try await Supa.client
                .from("users")
                .select("fname,lname,email")
                .eq("userid", value: userId)
                .single()
                .execute()
                .value

            fullName = "\(row.fname) \(row.lname)"
            email = row.email
        } catch {
            print("loadUser error:", error.localizedDescription)
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                Task { @MainActor in
                    self.notificationsEnabled = granted
                }
            }
    }
}
