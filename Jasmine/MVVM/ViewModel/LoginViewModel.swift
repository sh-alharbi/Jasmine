//
//  LoginViewModel.swift
//  Jasmine
//
//  Created by lamess on 07/06/1447 AH.
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
            self.error = error.localizedDescription
            return false
        }
    }

    func forgotPassword() async {
        error = nil
        isBusy = true
        defer { isBusy = false }

        do {
            try await Supa.client.auth.resetPasswordForEmail(email)
        } catch {
            self.error = error.localizedDescription
        }
    }
}
