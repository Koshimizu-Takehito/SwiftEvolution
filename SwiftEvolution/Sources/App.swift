import SwiftUI
import SwiftData

@main
struct App: SwiftUI.App {
    private let container = ModelContainer.appContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
        }
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

#if DEBUG
#Preview {
    PreviewContainer {
        ContentView()
    }
}
#endif
