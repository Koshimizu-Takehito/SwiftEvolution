import EvolutionModule
import SwiftUI

// MARK: - App

@main
/// Entry point for the Swift Evolution sample application.
struct App: SwiftUI.App {
    var body: some Scene {
        AppScene {
            ContentView()
        }
    }
}

// MARK: - Preview

#Preview(traits: .proposal) {
    ContentView()
        .environment(\.colorScheme, .dark)
}
