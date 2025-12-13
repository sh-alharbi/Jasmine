import SwiftUI
import Supabase

@main
struct JasmineApp: App {

    init() {
        UIView.appearance().overrideUserInterfaceStyle = .light
    }

    @StateObject var session = SessionStore()
    @StateObject var routineStore = RoutineStore()

    var body: some Scene {
        WindowGroup {
            Group {
                if session.userID != nil {
                    ActivityView()
                } else {
                    SplashView()
                }
            }
            .environmentObject(session)
            .environmentObject(routineStore)
           
        }
    }
}
