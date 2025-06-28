import SwiftData
import SwiftUI

@main
struct App: SwiftUI.App {
    private let sharedContainer = try! ModelContainer(
        for: ProposalObject.self,
        configurations: ModelConfiguration()
    )

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedContainer)
        }
        .commands {
            FilterCommands()
        }
#if os(macOS)
        Settings {
            SettingsView()
        }
#endif
    }
}
