import SwiftUI

private extension ProposalState? {
    var accentColor: (dark: String, light: String) {
        switch self {
        case .accepted:
            ("rgba(48,209,88,1)", "rgba(52,199,89,1)")
        case .activeReview:
            ("rgba(255,159,10,1)", "rgba(255,149,0,1)")
        case .implemented:
            ("rgba(10,132,255,1)", "rgba(0,122,255,1)")
        case .previewing:
            ("rgba(99,230,226,1)", "rgba(0,199,190,1)")
        case .rejected:
            ("rgba(255,69,58,1)", "rgba(255,59,48,1)")
        case .returnedForRevision:
            ("rgba(191,90,242,1)", "rgba(175,82,222,1)")
        case .withdrawn:
            ("rgba(255,69,58,1)", "rgba(255,59,48,1)")
        case nil:
            ("rgba(10,132,255,1)", "rgba(0,122,255,1)")
        }
    }
}

@Observable
final class Markdown {
    let proposal: Proposal
    private(set) var markdown = ""
    private(set) var html: String?

    init(proposal: Proposal) {
        self.proposal = proposal
        Task { try await self.fetch() }
    }

    func fetch() async throws {
        let url = URL(string: "https://raw.githubusercontent.com/apple/swift-evolution/main/proposals/\(proposal.link)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        self.markdown = (String(data: data, encoding: .utf8) ?? "")
            .replacingOccurrences(of: "\n", with: #"\n"#)
            .replacingOccurrences(of: "'", with: #"\'"#)
        self.html = buildHTML()
    }

    private var githubMarkdownCss: String {
        let (dark, light) = proposal.state.accentColor
        return String(data: NSDataAsset(name: "github-markdown")!.data, encoding: .utf8)!
            .replacingOccurrences(of: "$color-accent-fg-dark", with: dark)
            .replacingOccurrences(of: "$color-accent-fg-light", with: light)
    }

    private var markedJs: String {
        String(data: NSDataAsset(name: "marked.min")!.data, encoding: .utf8)!
    }

    private var highlightJs: String {
        String(data: NSDataAsset(name: "highlight.min")!.data, encoding: .utf8)!
    }

    private var proposalTemplateHTML: String {
        String(data: NSDataAsset(name: "proposal.template")!.data, encoding: .utf8)!
    }

    private func buildHTML() -> String {
        proposalTemplateHTML
            .replacingOccurrences(of: "$githubMarkdownCss", with: githubMarkdownCss)
            .replacingOccurrences(of: "$markedJs", with: markedJs)
            .replacingOccurrences(of: "$highlightJs", with: highlightJs)
            .replacingOccurrences(of: "$markdown", with: markdown)
    }
}

struct DetailView: View {
    @State var model: Markdown
    @State var isLoaded: Bool = false

    var body: some View {
        HTMLView(html: model.html, isLoaded: $isLoaded.animation(.default.delay(0.1)))
            .opacity(isLoaded ? 1 : 0)
            .navigationTitle(model.proposal.title)
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(edges: .bottom)
    }
}
