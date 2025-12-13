import Foundation
import Supabase
import Combine

@MainActor
class SessionStore: ObservableObject {

    @Published var userID: UUID?
    @Published var isGuest: Bool = false
    @Published var didShowRewardsAlertThisSession: Bool = false


    init() {
        Task { await loadSession() }
    }

    func loadSession() async {
        do {
            let session = try await Supa.client.auth.session
            self.userID = session.user.id
            print("✅ Session Loaded:", self.userID?.uuidString ?? "nil")

            if let uid = self.userID {
                Task {
                    do {
                        try await JasmineService.ensureRewardRowExists(userID: uid)
                        print("✅ reward_system row ensured")
                    } catch {
                        print("❌ ensureRewardRowExists error:", error.localizedDescription)
                    }
                }
            }

        } catch {
            print("❌ loadSession error:", error.localizedDescription)
            self.userID = nil
        }
    }

    func signOut() async {
        try? await Supa.client.auth.signOut()
        self.userID = nil
        self.isGuest = false
        self.didShowRewardsAlertThisSession = false
    }


}

extension SessionStore {
    var userUUID: UUID? { userID }
}


