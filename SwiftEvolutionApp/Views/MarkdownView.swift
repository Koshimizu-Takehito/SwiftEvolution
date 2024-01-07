import SwiftUI
import WebKit

struct MarkdownView: View {
    @Environment(\.modelContext) private var context

    let markdown: Markdown
    @Binding var path: NavigationPath
    @State private var isLoaded: Bool = false

    var body: some View {
        HTMLView(
            html: markdown.html,
            highlight: markdown.highlight,
            isLoaded: $isLoaded.animation(.default.delay(0.1))
        ) { linkID, url in
            if let proposal = ProposalObject.find(by: linkID, in: context) {
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
