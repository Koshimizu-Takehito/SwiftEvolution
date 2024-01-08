import SwiftUI
import SwiftData

extension ProposalDetailView {
    init(path: Binding<NavigationPath>, tint: Binding<Color?>, url: ProposalURL) {
        let markdown = Markdown(url: url)
        self.init(path: path, tint: tint, markdown: markdown)
    }
}

// MARK: - DetailView
struct ProposalDetailView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.modelContext) private var context
    @State private var isBookmarked: Bool = false
    @State private var isLoaded: Bool = false
    @Binding var path: NavigationPath
    @Binding var tint: Color?
    let markdown: Markdown

    var body: some View {
        // HTML
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
            // ツールバー
            ToolbarItemGroup(placement: toolbarItemPlacement) {
                HStack(spacing: 20) {
                    Spacer()
                    Button(action: toggleBookmark, label: {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .imageScale(.large)
                    })
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
                }
                .opacity(isLoaded ? 1 : 0)
            }
        }
        .onAppear {
            // ブックマークの状態を復元
            let object = ProposalObject.find(by: markdown.proposal.id, in: context)
            isBookmarked = object?.isBookmarked == true
        }
        .opacity(isLoaded ? 1 : 0)
        .navigationTitle(markdown.proposal.title)
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .bottom)
        .tint(stateColor)
    }

    var stateColor: Color? {
        markdown.proposal.state?.color
    }

    var toolbarItemPlacement: ToolbarItemPlacement {
        switch verticalSizeClass {
        case .regular:
            return .bottomBar
        case .compact:
            return .topBarTrailing
        default:
            return .automatic
        }
    }

    func toggleBookmark() {
        isBookmarked.toggle()
        let proposal = ProposalObject.find(by: markdown.proposal.id, in: context)
        guard let proposal else { return }
        proposal.isBookmarked = isBookmarked
        try? proposal.modelContext?.save()
    }

    func onTapURL(_ url: ProposalURL) {
        path.append(url)
    }
}

#Preview {
    PreviewContainer {
        NavigationStack {
            ProposalDetailView(path: .fake, tint: .fake, url: .fake0418)
        }
    }
}
