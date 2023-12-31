import SwiftUI

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
        String(data: NSDataAsset(name: "github-markdown")!.data, encoding: .utf8)!
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
