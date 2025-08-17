import EvolutionModule
import SwiftUI

// MARK: - App

@main
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
