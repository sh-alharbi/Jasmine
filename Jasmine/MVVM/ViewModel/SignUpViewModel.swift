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
            // 1) إنشاء حساب في Auth
            _ = try await Supa.client.auth.signUp(
                email: email,
                password: password
            )

            guard let session = try? await Supa.client.auth.session else {
                error = "Account created. Please verify your email, then sign in."
                return
            }

            let uid = session.user.id.uuidString

            // 2) تجهيز صف users
            struct NewUserRow: Encodable {
                let userid: String
                let fname: String
                let lname: String
                let email: String
                let dob: String
                let rewardpreference: Bool

                enum CodingKeys: String, CodingKey {
                    case userid, fname, lname, email, rewardpreference
                    case dob = "date_of_birth"
                }
            }

            let df = DateFormatter()
            df.calendar = Calendar(identifier: .gregorian)
            df.locale = Locale(identifier: "en_US_POSIX")
            df.timeZone = TimeZone(secondsFromGMT: 0)
            df.dateFormat = "yyyy-MM-dd"

            let row = NewUserRow(
                userid: uid,
                fname: fname,
                lname: lname,
                email: email,
                dob: df.string(from: dob),
                rewardpreference: false
            )

            // 3) إدخال الصف في Supabase
            do {
                try await Supa.client
                    .from("users")
                    .upsert(row, onConflict: "userid")
                    .execute()
            } catch {
                self.error = error.localizedDescription
                return
            }

            print("User created:", uid)

        } catch {
            self.error = error.localizedDescription
        }
    }
}

