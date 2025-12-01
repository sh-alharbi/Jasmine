//
//  JasmineApp.swift
//  Jasmine
//
//  Created by Shahad Alharbi on 10/25/25.
//
//
//import SwiftUI
//import Supabase
//
//@main
//struct JasmineApp: App {
//    @State private var userID: String? = nil
//    @StateObject var routineStore = RoutineStore()
//    
//    var body: some Scene {
//        WindowGroup {
//            ZStack {
// 
//                Group {
//                    if userID != nil {
//                        ContentView(onSignOut: {
//                            try? await Supa.client.auth.signOut()
//                            await MainActor.run {
//                                self.userID = nil
//                            }
//                        })
//                    } else {
//                     //   AuthContainerView(selectedMode: .login)
//                       WelcomeView()
//                    }
//                }
//            }
//            .environmentObject(routineStore)
//            .preferredColorScheme(.light)
//            .task {
//                if let session = try? await Supa.client.auth.session {
//                    userID = session.user.id.uuidString
//                } else if let session = Supa.client.auth.currentSession {
//                    userID = session.user.id.uuidString
//                } else {
//                    userID = nil
//                }
//            }
//        }
//    }
//}
//

import SwiftUI
import Supabase

@main
struct JasmineApp: App {

    @StateObject var session = SessionStore()
    @StateObject var routineStore = RoutineStore()

    var body: some Scene {
        WindowGroup {
            Group {
                if session.userID != nil {
                    ContentView(onSignOut: {
                        try? await Supa.client.auth.signOut()
                        await MainActor.run {
                            session.userID = nil
                        }
                    })
                } else {
                    WelcomeView()
                }
            }
            .environmentObject(session)
            .environmentObject(routineStore)
            .task {
                // استرجاع السشن إذا كان محفوظ
                if let sessionData = try? await Supa.client.auth.session {
                    session.userID = sessionData.user.id.uuidString
                } else if let existing = Supa.client.auth.currentSession {
                    session.userID = existing.user.id.uuidString
                } else {
                    session.userID = nil
                }
            }
        }
    }
}
