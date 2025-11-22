//
//  SignView.swift
//  Jasmine
//
//  Created by Shahad Alharbi on 11/5/25.
//

import SwiftUI
import Supabase

enum AuthMode: String, CaseIterable { case signup = "Sign-up", login = "Log-in" }

struct SignView: View {
    // UI state
    @State private var mode: AuthMode = .signup
    @State private var fname = ""
    @State private var lname = ""
    @State private var dob = Date(timeIntervalSince1970: 0)
    @State private var email = ""
    @State private var password = ""
    @State private var error: String?
    @State private var isBusy = false

    var onSignedIn: (String) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(mode == .signup ? "Create your Jasmine account" : "Welcome back to Jasmine")
                .font(.title3).bold()

            Picker("", selection: $mode) {
                Text("Sign-up").tag(AuthMode.signup)
                Text("Log-in").tag(AuthMode.login)
            }
            .pickerStyle(.segmented)

            Group {
                if mode == .signup {
                    TextField("First name", text: $fname)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .padding().background(.ultraThinMaterial).cornerRadius(10)

                    TextField("Last name", text: $lname)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .padding().background(.ultraThinMaterial).cornerRadius(10)

                    HStack {
                        Text("Date of birth")
                        Spacer()
                        DatePicker("", selection: $dob, displayedComponents: .date)
                            .labelsHidden()
                    }
                    .padding().background(.ultraThinMaterial).cornerRadius(10)
                }

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding().background(.ultraThinMaterial).cornerRadius(10)

                SecureField("Password", text: $password)
                    .padding().background(.ultraThinMaterial).cornerRadius(10)
            }

            if let error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }

            if mode == .login {
                Button("Forgot password?") {
                    Task { await forgotPassword() }
                }
                .font(.footnote)
            }

            Button(mode == .signup ? "Create account" : "Sign in") {
                Task {
                    if mode == .signup {
                        await handleSignUp()
                    } else {
                        await handleSignIn()
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isBusy || !canSubmit)
            .padding(.top, 8)

            if isBusy { ProgressView().padding(.top, 6) }
        }
        .padding()
    }

    var canSubmit: Bool {
        switch mode {
        case .signup:
            return !fname.isEmpty && !lname.isEmpty && !email.isEmpty && !password.isEmpty
        case .login:
            return !email.isEmpty && !password.isEmpty
        }
    }

    @MainActor
    private func handleSignUp() async {
        error = nil; isBusy = true
        defer { isBusy = false }
        do {
            // 1) إنشاء حساب
            _ = try await Supa.client.auth.signUp(email: email, password: password)

            // 2) الحصول على الجلسة
            guard let session = try? await Supa.client.auth.session else {
                error = "Account created. Please verify your email, then sign in."
                return
            }
            let uid = session.user.id.uuidString

            struct NewUserRow: Encodable {
                let userid: String
                let fname: String
                let lname: String
                let email: String
                let dob: String        // yyyy-MM-dd
                let rewardpreference: Bool
            }
            let df = DateFormatter()
            df.calendar = Calendar(identifier: .gregorian)
            df.locale = .init(identifier: "en_US_POSIX")
            df.timeZone = .init(secondsFromGMT: 0)
            df.dateFormat = "yyyy-MM-dd"


            let row = NewUserRow(
                userid: uid,
                fname: fname,
                lname: lname,
                email: email,
                dob: df.string(from: dob),
                rewardpreference: false
            )

            try await Supa.client
                .from("users")
                .upsert(row, onConflict: "userid")
                .execute()

            onSignedIn(uid)
        } catch {
            self.error = prettify(error)
        }
    }

    @MainActor
       private func handleSignIn() async {
           error = nil; isBusy = true
           defer { isBusy = false }
           do {
               _ = try await Supa.client.auth.signIn(email: email, password: password)
               let session = try await Supa.client.auth.session
               onSignedIn(session.user.id.uuidString)
           } catch {
               let msg = error.localizedDescription.lowercased()

               if msg.contains("invalid login") {
                   self.error = "Account not found. Please sign up first."
               } else {
                   self.error = "Login failed. Please try again."
               }
           }
       }

    @MainActor
    private func forgotPassword() async {
        error = nil; isBusy = true
        defer { isBusy = false }
        do {
            try await Supa.client.auth.resetPasswordForEmail(email)
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func prettify(_ error: Error) -> String {
        let msg = error.localizedDescription
        if msg.localizedCaseInsensitiveContains("duplicate key value violates unique constraint") {
            return "This email is already registered."
        }
        if msg.localizedCaseInsensitiveContains("permission denied") ||
            msg.localizedCaseInsensitiveContains("row-level security") {
            return "Database policy blocked the insert. Check RLS for table users."
        }
        return "Database error saving new user"
    }
}

struct SignView_Previews: PreviewProvider {
    static var previews: some View {
        SignView(onSignedIn: { _ in })
    }
}
