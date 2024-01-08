import SwiftUI
import SwiftData

@main
struct App: SwiftUI.App {
    @State var stateOptions = PickedStates()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(stateOptions)
        }
        .modelContainer(for: ProposalObject.self)
    }
}

#Preview {
    PreviewContainer {
        ContentView()
    }
}
