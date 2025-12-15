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

    var isOver18: Bool {
        let calendar = Calendar.current
        let age = calendar.dateComponents([.year], from: dob, to: Date()).year ?? 0
        return age >= 18
    }

    var canSubmit: Bool {
        !fname.isEmpty &&
        !lname.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        isOver18
        
    }
    private func formattedDOB() -> String {
          let df = DateFormatter()
          df.calendar = Calendar(identifier: .gregorian)
          df.locale = Locale(identifier: "en_US_POSIX")
          df.timeZone = TimeZone(secondsFromGMT: 0)
          df.dateFormat = "yyyy-MM-dd"
          return df.string(from: dob)
      }

    func signUp() async {
        error = nil
        guard isOver18 else {
              error = "You must be 18 years or older"
              return
          }
        isBusy = true
        defer { isBusy = false }

        do {
            let dobString = formattedDOB()
        

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
            
            struct UsersRow: Encodable {
                let userid: UUID
                let fname: String
                let lname: String
                let email: String
                let rewardpreference: Bool
                let notificationpreference: Bool
                let date_of_birth: String
            }

            let userRow = UsersRow(
                userid: response.user.id,
                fname: fname,
                lname: lname,
                email: email,
                rewardpreference: false,
                notificationpreference: false,
                date_of_birth: dobString
            )

            try await Supa.client
                .from("users")
                .insert(userRow)
                .execute()

            print("✅ users row created")


        } catch {
            let msg = error.localizedDescription.lowercased()

            if msg.contains("row-level security") {
                print("ℹ️ RLS warning ignored:", error.localizedDescription)
                return
            }

            self.error = error.localizedDescription
            print("❌ signUp error:", error.localizedDescription)
        }

    }
}
