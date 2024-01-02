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
            codeHighlight: model.codeHighlight,
            isLoaded: $isLoaded.animation(.default.delay(0.1))
        ) { linkID, url in
            if let proposal = list.proposal(id: linkID) {
                path.append(ProposalURL(proposal, url))
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                Menu {
                    ForEach(CodeHighlight.allCases) { item in
                        Button(item.displayName) {
                            model.codeHighlight = item
                        }
                    }
                } label: {
                    Image(systemName: "gearshape")
                        .imageScale(.large)
                }
                .menuOrder(.fixed)
                .opacity(isLoaded ? 1 : 0)
            }
        }
        .opacity(isLoaded ? 1 : 0)
        .navigationTitle(model.proposal.title)
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .bottom)
    }
}

private struct CodeHighlightItem: View {
    let value: CodeHighlight
    let selected: (CodeHighlight) -> Void

    var body: some View {
        Button(value.rawValue) {
            selected(value)
        }
    }
}
