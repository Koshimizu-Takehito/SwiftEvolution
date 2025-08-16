import EvolutionModel
import EvolutionModule
import EvolutionUI
import SwiftData
import SwiftUI

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            ContentView().modelContainer(for: ProposalObject.self)
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

#Preview(traits: .proposal) {
    ContentView().environment(\.colorScheme, .dark)
}

#Preview("Landscape", traits: .proposal, .landscapeLeft) {
    ContentView().environment(\.colorScheme, .dark)
}

#Preview("Assistive access", traits: .proposal, .assistiveAccess) {
    ContentView().environment(\.colorScheme, .dark)
}

#Preview("Landscape", traits: .proposal, .landscapeLeft, .assistiveAccess) {
    ContentView().environment(\.colorScheme, .dark)
}
