import SwiftUI

extension ProposalDetailView {
    init(path: Binding<NavigationPath>, tint: Binding<Color?>, url: ProposalURL) {
        let markdown = Markdown(url: url)
        self.init(path: path, tint: tint, markdown: markdown)
    }
}

// MARK: - DetailView
struct ProposalDetailView: View {
    @Environment(\.modelContext) private var context
    @State private var isLoaded: Bool = false
    @Binding var path: NavigationPath
    @Binding var tint: Color?
    let markdown: Markdown

    var body: some View {
        HTMLView(
            html: markdown.html,
            highlight: markdown.highlight,
            isLoaded: $isLoaded.animation(),
            onTap: onTapURL
        )
        .onChange(of: stateColor, initial: true) {
            tint = stateColor
        }
        .toolbar {
            toolbar
        }
        .opacity(isLoaded ? 1 : 0)
        .navigationTitle(markdown.proposal.title)
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .bottom)
        .tint(stateColor)
    }

    func onTapURL(_ url: ProposalURL) {
        path.append(url)
    }
}

private extension ProposalDetailView {
    var stateColor: Color? {
        markdown.proposal.state?.color
    }

    var toolbar: some ToolbarContent {
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
}

#Preview {
    PreviewContainer {
        ProposalDetailView(path: .fake, tint: .fake, url: .fake0418)
    }
}
