//  LoginViewModel.swift
//  Jasmine
//

import Foundation
import Supabase
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isBusy = false
    @Published var error: String?

    var canSubmit: Bool {
        !email.isEmpty && !password.isEmpty
    }

    // تسجيل الدخول
    func login() async -> Bool {
        error = nil
        isBusy = true
        defer { isBusy = false }

        do {
            _ = try await Supa.client.auth.signIn(
                email: email,
                password: password
            )
            return true
        } catch {
            self.error = "Invalid login credentials"
            print("login error:", error.localizedDescription)
            return false
        }
    }
}
