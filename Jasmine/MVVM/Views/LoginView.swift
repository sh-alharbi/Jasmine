//
//  LoginView.swift
//  Jasmine
//
//  Created by lamess on 07/06/1447 AH.
//
//import SwiftUI
//
//struct LoginView: View {
//    @StateObject var viewModel = LoginViewModel()
//    @State private var showSignup = false
//
//    var body: some View {
//        VStack(spacing: 20) {
//
//            Text("Welcome back to Jasmine")
//                .font(.title3)
//                .bold()
//
//            TextField("Email", text: $viewModel.email)
//                .keyboardType(.emailAddress)
//                .padding()
//                .background(.ultraThinMaterial)
//                .cornerRadius(10)
//
//            SecureField("Password", text: $viewModel.password)
//                .padding()
//                .background(.ultraThinMaterial)
//                .cornerRadius(10)
//
//            if let error = viewModel.error {
//                Text(error)
//                    .foregroundColor(.red)
//                    .font(.footnote)
//            }
//
//            Button("Sign in") {
//                Task { await viewModel.login() }
//            }
//            .buttonStyle(.borderedProminent)
//            .disabled(!viewModel.canSubmit || viewModel.isBusy)
//
//            if viewModel.isBusy {
//                ProgressView()
//            }
//
//            // رابط الذهاب لصفحة التسجيل
//            Button("Don't have an account? Sign up") {
//                showSignup = true
//            }
//            .font(.footnote)
//            .padding(.top, 8)
//        }
//        .padding()
//        .fullScreenCover(isPresented: $showSignup) {
//            SignUpView()
//        }
//    }
//}
import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    @State private var showSignup = false

    var body: some View {
        ZStack {
            // الخلفية
            LinearGradient(
                colors: [
                    Color(red: 153/255, green: 188/255, blue: 148/255),
                    Color(red: 238/255, green: 246/255, blue: 236/255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {

                Spacer().frame(height: 40)

                // اللوجو
                Image("JasmineLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140)

                Text("Jasmine")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.black.opacity(0.75))
                    .padding(.bottom, 20)

                // Email Field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Email")
                        .font(.footnote)
                        .foregroundColor(.gray)

                    TextField("", text: $viewModel.email)
                        .padding()
                        .background(.white.opacity(0.9))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never).glassEffect(.clear)
                }

                // Password Field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Password")
                        .font(.footnote)
                        .foregroundColor(.gray)

                    SecureField("*************", text: $viewModel.password)
                        .padding()
                        .background(.white.opacity(0.9))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.08), radius: 4, y: 2).glassEffect(.clear)
                }

                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top, 4)
                }

                // Login Button
                Button {
                    Task { await viewModel.login() }
                } label: {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 153/255, green: 188/255, blue: 148/255))
                        .foregroundColor(.white)
                        .font(.headline)
                        .cornerRadius(28)
                        .padding(.top, 10)
                }
                .disabled(!viewModel.canSubmit || viewModel.isBusy)

                if viewModel.isBusy {
                    ProgressView().padding(.top, 4)
                }

                // Link to Signup
                Button {
                    showSignup = true
                } label: {
                    Text("Don’t have an account")
                        .font(.footnote)
                        .underline()
                        .foregroundColor(.black)
                        .padding(.top, 12)
                }

                Spacer()
            }
            .padding(.horizontal, 28)
        }
        .fullScreenCover(isPresented: $showSignup) {
            SignUpView()
        }
    }
}

#Preview {
    LoginView()
}
