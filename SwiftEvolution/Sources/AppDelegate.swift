import SwiftUI
import CoreSpotlight

// MARK: - AppDelegateAdaptor
#if os(iOS)
typealias AppDelegateAdaptor<T: NSObject & UIApplicationDelegate> = UIApplicationDelegateAdaptor<T>
#elseif os(macOS)
typealias AppDelegateAdaptor<T: NSObject & NSApplicationDelegate> = NSApplicationDelegateAdaptor<T>
#endif

// MARK: - AppDelegate
#if os(iOS)
@MainActor
final class AppDelegate: UIResponder, UIApplicationDelegate, ObservableObject {
    func application(
        _: UIApplication,
        configurationForConnecting sceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(
            name: nil,
            sessionRole: sceneSession.role
        )
        if sceneSession.role == .windowApplication {
            configuration.delegateClass = SceneDelegate.self
        }
        return configuration
    }
}
#elseif os(macOS)
final class AppDelegate: NSResponder, NSApplicationDelegate {
}
#endif
