import SwiftUI
import WebKit

struct MarkdownView: View {
    let markdown: Markdown
    @Binding var path: NavigationPath
    @State private var isLoaded: Bool = false
    @Environment(ProposalList.self) private var list

    var body: some View {
        HTMLView(
            html: markdown.html,
            highlight: markdown.highlight,
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
                    ForEach(SyntaxHighlight.allCases) { item in
                        Button(item.displayName) {
                            markdown.highlight = item
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
        .navigationTitle(markdown.proposal.title)
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .bottom)
    }
}

private struct CodeHighlightItem: View {
    let value: SyntaxHighlight
    let selected: (SyntaxHighlight) -> Void

    var body: some View {
        Button(value.rawValue) {
            selected(value)
        }
    }
}
