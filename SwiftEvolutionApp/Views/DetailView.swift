import SwiftUI

struct DetailView: View {
    let model: Markdown
    @Binding var path: NavigationPath
    @State private var isLoaded: Bool = false
    @Environment(ProposalList.self) private var list

    var body: some View {
        HTMLView(
            html: model.html,
            isLoaded: $isLoaded.animation(.default.delay(0.1))
        ) { linkID in
            if let proposal = list.proposal(id: linkID) {
                path.append(proposal)
            }
        }
        .opacity(isLoaded ? 1 : 0)
        .navigationTitle(model.proposal.title)
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .bottom)
    }
}
