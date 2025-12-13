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
    @State private var dob = Date()
    @State private var goToActivity = false

    func isOver18() -> Bool {
        let calendar = Calendar.current
        let age = calendar.dateComponents([.year], from: dob, to: Date()).year ?? 0
        return age >= 18
    }

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

                TextField("First Name", text: $viewModel.fname)
                    .padding()
                    .background(.white.opacity(0.9))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

                TextField("Last Name", text: $viewModel.lname)
                    .padding()
                    .background(.white.opacity(0.9))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

                Button {
                    showCalendar.toggle()
                } label: {
                    HStack {
                        Text(dob.formatted(date: .abbreviated, time: .omitted))
                            .foregroundColor(.black.opacity(0.7))
                        Spacer()
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                }
                .popover(isPresented: $showCalendar, arrowEdge: .bottom) {
                    DatePicker(
                        "Date",
                        selection: $dob,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .padding()
                }

                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(.white.opacity(0.9))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)

                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .background(.white.opacity(0.9))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                Button {
                    if isOver18() {
                        Task { await viewModel.signUp() }
                    } else {
                        viewModel.error = "You must be 18 years or older"
                    }
                } label: {
                    Text("Create account")
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
                    ProgressView()
                }

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

                Button {
                    showLogin = true
                } label: {
                    Text("Already have an account? Log in")
                        .font(.footnote)
                        .underline()
                        .foregroundColor(.black)
                        .padding(.top, 12)
                }

                Spacer()
            }
            .padding(.horizontal, 28)
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

#Preview {
    SignUpView()
        .environmentObject(SessionStore())
        .environmentObject(RoutineStore())
}
