import SwiftUI
import SwiftData

@main
struct App: SwiftUI.App {
    @AppDelegateAdaptor<AppDelegate> private var delegate

    private let sharedContainer = try! ModelContainer(
        for: ProposalObject.self,
        configurations: ModelConfiguration()
    )

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedContainer)
        }
#if os(macOS)
        Settings {
            SettingsView()
        }
#endif
    }
}

import AppIntents

struct FooIntent: AppIntent {
    static let title: LocalizedStringResource = "Swift"
    static let description: LocalizedStringResource = "Swift Evolution"
    static let openAppWhenRun: Bool = true

    @MainActor func perform() async throws -> some IntentResult {
        .result()
    }
}

struct FooShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: FooIntent(),
            phrases: ["\(.applicationName)"],
            shortTitle: "Swift",
            systemImageName: "star.fill"
        )
    }
}
