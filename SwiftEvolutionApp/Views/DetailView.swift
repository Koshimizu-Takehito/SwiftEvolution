import SwiftUI
import WebKit

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
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                Menu {
                    ForEach(CodeHighlight.allCases.reversed()) {
                        CodeHighlightItem(action: update, value: $0)
                    }
                } label: {
                    Image(systemName: "gearshape")
                        .imageScale(.large)
                }
                .opacity(isLoaded ? 1 : 0)
            }
        }
        .opacity(isLoaded ? 1 : 0)
        .navigationTitle(model.proposal.title)
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .bottom)
    }

    func update(_ highlight: CodeHighlight) {
        print(highlight)
    }
}

private struct CodeHighlightItem: View {
    let action: (CodeHighlight) -> Void
    let value: CodeHighlight

    var body: some View {
        Button(value.rawValue) {
            action(value)
        }
    }
}
