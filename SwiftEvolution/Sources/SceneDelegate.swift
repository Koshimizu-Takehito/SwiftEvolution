import SwiftUI
import CoreSpotlight

struct Publication<V: Hashable>: Hashable, Identifiable {
    let id = UUID()
    let value: V
}

// MARK: - SceneDelegate
#if os(iOS)
@MainActor
class SceneDelegate: UIResponder, UIWindowSceneDelegate, ObservableObject {
    @Published private(set) var proposalID: Publication<ProposalID>?

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == CSSearchableItemActionType,
              let identifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String,
              let match = identifier.firstMatch(of: /SE-\d+/)
        else {
            return
        }
        proposalID = .init(value: String(match.0))
    }
}
#endif
