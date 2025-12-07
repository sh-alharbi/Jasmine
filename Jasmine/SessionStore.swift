//
//  SessionStore.swift
//  Jasmine
//
//  Created by lamess on 09/06/1447 AH.
//
import Foundation
import Supabase
import Combine

@MainActor
class SessionStore: ObservableObject {

    @Published var userID: String?

    init() {
        Task {
            await loadSession()
        }
    }

    func loadSession() async {
        do {
            let session = try await Supa.client.auth.session
            self.userID = session.user.id.uuidString
            print("✅ Session Loaded:", self.userID ?? "nil")
        } catch {
            print("❌ No active session in SessionStore")
            self.userID = nil
        }
    }

    func signOut() async {
        try? await Supa.client.auth.signOut()
        self.userID = nil
    }
}
