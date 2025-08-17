import EvolutionModule
import SwiftUI

@main
struct App: SwiftUI.App {
    var body: some Scene {
        AppScene {
            ContentView()
        }
    }
}

#Preview(traits: .proposal) {
    ContentView()
        .environment(\.colorScheme, .dark)
}
