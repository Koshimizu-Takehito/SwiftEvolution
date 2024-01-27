import SwiftUI
import SwiftData

@main
struct App: SwiftUI.App {
    @State var status = PickedStatus()
    let modelContainer: ModelContainer = .appContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(status)
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
        let proposal = ModelConfiguration(
            schema: Schema([ProposalObject.self]),
            cloudKitDatabase: .none
        )
        do {
            return try ModelContainer(
                for: ProposalObject.self,
                configurations: proposal
            )
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}