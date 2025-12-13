////
////  WelcomeView.swift
////  Jasmine
////
////  Created by lamess on 01/06/1447 AH.
////

import SwiftUI

struct WelcomeView: View {
    @State private var showLogin = false
    @State private var showSignup = false
    @EnvironmentObject var session: SessionStore
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

            VStack(spacing: 20) {

                Image("JasmineLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180)

                Text("Jasmine")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.black.opacity(0.85))

                Spacer().frame(height: 10)

                Button {
                    showLogin = true
                } label: {
                    Text("Login")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 153/255, green: 188/255, blue: 148/255))
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
                .glassEffect()

                
                Button {
                    showSignup = true
                } label: {
                    Text("Signup")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black.opacity(0.8))
                        .cornerRadius(25)
                }
                .glassEffect()

                Button {
                    session.isGuest = true
                    goToActivity = true
                } label: {
                    Text("Continue as a guest")
                        .underline()
                        .foregroundColor(.black)
                }
                .padding(.top, 12)

                Spacer()
            }
            .padding(.horizontal, 32)
            .padding(.top, 60)
        }
        .fullScreenCover(isPresented: $showLogin) {
            LoginView()
            .environmentObject(session)

        }
        .fullScreenCover(isPresented: $showSignup) {
            SignUpView()
                .environmentObject(session)

        }
        .fullScreenCover(isPresented: $goToActivity) {
            ActivityView()
                .environmentObject(session)
                .environmentObject(RoutineStore())
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(SessionStore())
        .environmentObject(RoutineStore())
}
