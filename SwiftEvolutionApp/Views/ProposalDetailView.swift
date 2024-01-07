import SwiftUI

// MARK: - DetailView
struct ProposalDetailView: View {
    @Binding var path: NavigationPath
    @Binding var proposal: Proposal?
    let url: ProposalURL

    var body: some View {
        // 詳細画面
        let proposal = url.proposal
        let markdown = Markdown(proposal: proposal, url: url.url)
        MarkdownView(markdown: markdown, path: $path)
            .onChange(of: proposal, initial: true) {
                self.proposal = proposal
            }
            .tint(proposal.state?.color)
    }
}

#Preview {
    PreviewContainer {
        ProposalDetailView(path: .fake, proposal: .fake, url: .fake0418)
    }
}
