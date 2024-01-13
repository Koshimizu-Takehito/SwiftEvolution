import SwiftUI
import SwiftData

@main
struct App: SwiftUI.App {
    @State var status = PickedStatus()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(status)
        }
        .modelContainer(for: ProposalObject.self)
    }
}

#Preview {
    PreviewContainer {
        ContentView()
    }
}
