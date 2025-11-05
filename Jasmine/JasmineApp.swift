//
//  testfApp.swift
//  testf
//
//  Created by Shahad Alharbi on 10/25/25.
//

import SwiftUI
import Supabase

@main
struct JasmineApp: App {
    @State private var userID: String? = nil

    var body: some Scene {
        WindowGroup {
            Group {
                if userID != nil {
                    ContentView()
                } else {
                    // ✅ مرري الإغلاق المطلوب
                    SignView { uid in
                        self.userID = uid
                    }
                }
            }
            .preferredColorScheme(.light)
            .task {
                // محاولة جلب جلسة حالية
                if let session = try? await Supa.client.auth.session {
                    userID = session.user.id.uuidString
                } else if let session = Supa.client.auth.currentSession {
                    userID = session.user.id.uuidString
                } else {
                    userID = nil
                }
            }
        }
    }
}
