import SwiftUI

struct RootView: View {
    var body: some View {
        ContentView()
            .environment(ProposalList())
            .environment(ProposalStateOptions())
    }
}

#Preview {
    RootView()
}
