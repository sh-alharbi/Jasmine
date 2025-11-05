//
//  AuthView.swift
//  testf
//
//  Created by Shahad Alharbi on 11/5/25.
//

import SwiftUI
import Supabase

struct SignView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var error: String?
    @State private var isBusy = false

    // اذا ضبط ال sign in يروح ل  JasmineApp
    var onSignedIn: (String) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Sign in to Jasmine").font(.title2).bold()

            TextField("Email", text: $email)
            // نوعه ايميل
                .keyboardType(.emailAddress)
            // ابل تخللي اول حرف دايم كبتل ، شلنا هذا الشي
                .textInputAutocapitalization(.never)
            // عدم التعديل
                .autocorrectionDisabled()
                .padding().background(.ultraThinMaterial).cornerRadius(10)

            SecureField("Password", text: $password)
                .padding().background(.ultraThinMaterial).cornerRadius(10)

            if let error {
                // نظهر الايرور لليوزر
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 12) {
                Button("Sign Up") {
                    Task { await signUp() }
                }
                // عطل الزر اذا كان اليوزر مشغول او الايميل فاضي او الباسورد
                .disabled(isBusy || email.isEmpty || password.isEmpty)

                Button("Sign In") {
                    Task { await signIn() }
                }
                .disabled(isBusy || email.isEmpty || password.isEmpty)
            }
            .buttonStyle(.borderedProminent)

            if isBusy { ProgressView().padding(.top, 6) }
        }
        .padding()
    }

    @MainActor
    private func signUp() async {
        error = nil; isBusy = true
        defer { isBusy = false }
        do {
            // 1) يسوي اكاونت في سوبا
            _ = try await Supa.client.auth.signUp(email: email, password: password)
            // 2) محاولة جلب جلسة مباشرة
            if let session = try? await Supa.client.auth.session {
                onSignedIn(session.user.id.uuidString)
                return
            }

            // 3) لو تفعيل تأكيد الإيميل موجود، ما راح يرجع session الآن
            error = "Account has been created! Please verify your email, then Sign In."
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    // بعد ماسوا اكاونت يسجل دخول

    @MainActor
    private func signIn() async {
        error = nil; isBusy = true
        defer { isBusy = false }
        do {
            // تسجيل الدخول ببريد/كلمة مرور
            _ = try await Supa.client.auth.signIn(email: email, password: password)
            // الحصول على الجلسة المحدثة
            let session = try await Supa.client.auth.session
            onSignedIn(session.user.id.uuidString)
        } catch {
            self.error = error.localizedDescription
        }
    }
}
