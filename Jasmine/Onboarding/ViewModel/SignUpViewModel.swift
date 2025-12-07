//
//  SignUpViewModel.swift
//  Jasmine
//
//  Created by lamess on 07/06/1447 AH.
//

import Foundation
import Supabase
import Combine

@MainActor
final class SignUpViewModel: ObservableObject {
    @Published var fname = ""
    @Published var lname = ""
    @Published var dob = Date()
    @Published var email = ""
    @Published var password = ""
    @Published var isBusy = false
    @Published var error: String?

    var canSubmit: Bool {
        !fname.isEmpty &&
        !lname.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty
    }

    func signUp() async {
        error = nil
        isBusy = true
        defer { isBusy = false }

        do {
            let df = DateFormatter()
            df.calendar = Calendar(identifier: .gregorian)
            df.locale = Locale(identifier: "en_US_POSIX")
            df.timeZone = TimeZone(secondsFromGMT: 0)
            df.dateFormat = "yyyy-MM-dd"
            let dobString = df.string(from: dob)

            let metadata: [String: AnyJSON] = [
                "fname": .string(fname),
                "lname": .string(lname),
                "date_of_birth": .string(dobString),
                "rewardpreference": .bool(false)
            ]

            let response = try await Supa.client.auth.signUp(
                email: email,
                password: password,
                data: metadata
            )

            if response.session == nil {
                self.error = "Account created. Please verify your email, then log in."
            } else {
                print("✅ Signed up & logged in:", response.user.id)
            }

            print("✅ Auth user created:", response.user.id)

        } catch {
            self.error = error.localizedDescription
            print("❌ signUp error:", error.localizedDescription)
        }
    }
}
