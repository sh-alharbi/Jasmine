////
////  SplashScreen.swift
////  Jasmine
////
////  Created by lamess on 01/06/1447 AH.
////
//
import SwiftUI

struct SplashView: View {
    @State private var animate = false
    @State private var isActive = false   // New

    var body: some View {
        if isActive {
            WelcomeView()   // الصفحة اللي بعدها
        } else {
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

                Image("JasmineLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250)
                    .scaleEffect(animate ? 1.0 : 0.7)
                    .opacity(animate ? 1 : 0)
                    .animation(.easeOut(duration: 1.3), value: animate)
            }
            .onAppear {
                animate = true
                
                // الانتقال بعد مدة
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
