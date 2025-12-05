//
//  SignUpView.swift
//  Jasmine
//
//  Created by lamess on 07/06/1447 AH.
//
import SwiftUI

struct SignUpView: View {
    @StateObject var viewModel = SignUpViewModel()
    @State private var showLogin = false
    @State private var showCalendar = false
    @State private var dob = Date()
    var action: () -> Void = { }
    
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
                
                // اللوجو نفس Login
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
                VStack(alignment: .leading, spacing: 6) {
                    
                    
                    TextField("First Name", text: $viewModel.fname)
                        .padding()
                        .background(.white.opacity(0.9))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                }
                
                // Last Name
                VStack(alignment: .leading, spacing: 6) {
                    
                    
                    TextField("Last Name", text: $viewModel.lname)
                        .padding()
                        .background(.white.opacity(0.9))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    
                    
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
                            "Date ",
                            selection: $dob,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .padding()
                    }
                }
                
                
                
                // Email
                VStack(alignment: .leading, spacing: 6) {
                    
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(.white.opacity(0.9))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
                
                // Password
                VStack(alignment: .leading, spacing: 6) {
                    
                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .background(.white.opacity(0.9))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                }
                
                // Error
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                
                // Create Account Button — نفس زر Login
                Button {
                    Task { await viewModel.signUp() }
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
                
                Button(action: action){
                    Text("Continue as a guest")
                        .foregroundColor(.black) // أخضر
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color(red: 153/255, green: 188/255, blue: 148/255), lineWidth: 2)
                        )
                }.glassEffect()
                
                // Link to login
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
        }
    }
}

#Preview {
    SignUpView()
}
