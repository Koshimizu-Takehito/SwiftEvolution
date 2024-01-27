import SwiftUI
import SwiftData

@main
struct App: SwiftUI.App {
    let modelContainer: ModelContainer = .appContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
#if os(macOS)
        Settings {
            SettingsView()
        }
#endif
    }
}

private extension ModelContainer {
    static func appContainer() -> ModelContainer {
        do {
            return try ModelContainer(
                for: ProposalObject.self,
                configurations: ModelConfiguration()
            )
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
