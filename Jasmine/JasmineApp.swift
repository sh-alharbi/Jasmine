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
                    
                    ActivityView()
                } else {
                    WelcomeView()
                }
            }
            .environmentObject(session)
            .environmentObject(routineStore)
            .task {
                // استرجاع السِشن إذا كان محفوظ
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
