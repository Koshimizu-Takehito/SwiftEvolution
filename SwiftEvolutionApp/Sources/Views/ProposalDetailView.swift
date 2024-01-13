import SwiftUI
import SwiftData

extension ProposalDetailView {
    init(
        path: Binding<NavigationPath>,
        tint: Binding<Color?> = .constant(nil),
        url: ProposalURL
    ) {
        let markdown = Markdown(url: url)
        self.init(path: path, tint: tint, markdown: markdown)
    }
}

// MARK: - DetailView
struct ProposalDetailView: View {
    @Environment(\.verticalSizeClass) var vertical
    @Environment(\.modelContext) private var context
    @State private var isBookmarked: Bool = false
    @State private var isLoaded: Bool = false
    @Binding var path: NavigationPath
    @Binding var tint: Color?
    let markdown: Markdown

    var body: some View {
        // HTML
        ProposalDetailWebView(
            html: markdown.html,
            highlight: markdown.highlight,
            isLoaded: $isLoaded.animation(),
            onTap: onTapURL
        )
        .toolbar {
            // ツールバー
            toolbar
        }
        .onAppear {
            // ブックマークの状態を復元
            let object = ProposalObject[markdown.proposal.id, in: context]
            isBookmarked = object?.isBookmarked == true
        }
        .onChange(of: isBookmarked) { _, new in
            saveBookmark(isBookmarked: new)
        }
        .onChange(of: stateColor, initial: true) {
            tint = stateColor
        }
        .opacity(isLoaded ? 1 : 0)
        .navigationTitle(markdown.proposal.title)
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .bottom)
        .tint(stateColor)
    }

    /// ツールバー
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        let placement: ToolbarItemPlacement = switch vertical {
        case .regular:
            .bottomBar
        case .compact:
            .topBarTrailing
        default:
            .automatic
        }
        ToolbarItemGroup(placement: placement) {
            HStack {
                Spacer()
                BookmarkButton(isBookmarked: $isBookmarked)
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
}

private extension ProposalDetailView {
    var stateColor: Color? {
        markdown.proposal.state?.color
    }

    func saveBookmark(isBookmarked: Bool) {
        let proposal = ProposalObject[markdown.proposal.id, in: context]
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
