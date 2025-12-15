//
//  SignUpView.swift
//  Jasmine
//
import SwiftUI
import Supabase

struct SignUpView: View {

    @StateObject var viewModel = SignUpViewModel()

    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var routineStore: RoutineStore

    @State private var showLogin = false
    @State private var showCalendar = false
    @State private var goToActivity = false

    var body: some View {
        ZStack {
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

                Image("JasmineLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140)

                Text("Create your Jasmine account")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.black.opacity(0.75))
                    .padding(.bottom, 10)

                // First Name
                TextField("First Name", text: $viewModel.fname)
                    .padding()
                    .background(.white.opacity(0.9))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

                // Last Name
                TextField("Last Name", text: $viewModel.lname)
                    .padding()
                    .background(.white.opacity(0.9))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

                // DOB (custom popup)
                HStack {
                    Text(viewModel.dob.formatted(date: .abbreviated, time: .omitted))
                        .foregroundColor(.black.opacity(0.7))

                    Spacer()

                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                .onTapGesture {
                    withAnimation { showCalendar = true }
                }

                // Email
                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .padding()
                    .background(.white.opacity(0.9))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

                // Password
                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .background(.white.opacity(0.9))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

                // Error
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                // Create Account
                Button {
                    Task { await viewModel.signUp() }
                } label: {
                    Text("Create account")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            viewModel.canSubmit
                            ? Color(red: 153/255, green: 188/255, blue: 148/255)
                            : Color(red: 153/255, green: 188/290, blue: 148/255)    )
                        .foregroundColor(.white)
                        .font(.headline)
                        .cornerRadius(28)
                }
//                .disabled(!viewModel.canSubmit || viewModel.isBusy)

                if viewModel.isBusy {
                    ProgressView()
                }

                // Guest
                Button {
                    session.isGuest = true
                    goToActivity = true
                } label: {
                    Text("Continue as a guest")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color(red: 153/255, green: 188/255, blue: 148/255), lineWidth: 2)
                        )
                }
                .glassEffect()

                // Login
                Button {
                    showLogin = true
                } label: {
                    Text("Already have an account? Log in")
                        .font(.footnote)
                        .underline()
                        .foregroundColor(.black)
                }

                Spacer()
            }
            .padding(.horizontal, 28)

            // 🔽 DOB popup
            if showCalendar {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { showCalendar = false }
                    }

                VStack(spacing: 12) {
                    DatePicker(
                        "",
                        selection: $viewModel.dob,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .labelsHidden()

                    Button("Done") {
                        withAnimation { showCalendar = false }
                    }
                    .font(.headline)
                }
                .padding()
                .background(.white)
                .cornerRadius(20)
                .shadow(radius: 12)
                .frame(width: 330, height: 380)
                .transition(.scale)
            }
        }
        .fullScreenCover(isPresented: $showLogin) {
            LoginView()
                .environmentObject(session)
                .environmentObject(routineStore)
        }
        .fullScreenCover(isPresented: $goToActivity) {
            ActivityView()
                .environmentObject(session)
                .environmentObject(routineStore)
        }
    }
}

#Preview { SignUpView() .environmentObject(SessionStore()) .environmentObject(RoutineStore()) }
