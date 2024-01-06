import SwiftUI
import SwiftData

@main
struct App: SwiftUI.App {
    @State var stateOptions = ProposalStateOptions()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(stateOptions)
        }
        .modelContainer(for: Proposal.self)
    }
}

#Preview {
    @State var stateOptions = ProposalStateOptions()
    return ContentView()
        .environment(stateOptions)
}
