import SwiftUI
import SwiftData

// MARK: - ListView
struct ProposalListView: View {
    let horizontal: UserInterfaceSizeClass?
    @Binding var selection: Markdown?
    @Query private var proposals: [ProposalObject]
    let status: Set<ProposalStatus>

    init(
        horizontal: UserInterfaceSizeClass?,
        selection: Binding<Markdown?>,
        status: Set<ProposalStatus>,
        isBookmarked: Bool
    ) {
        self.horizontal = horizontal
        self.status = status
        _selection = selection
        _proposals = .query(
            status: status, isBookmarked: isBookmarked
        )
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(proposals) { proposal in
                NavigationLink(value: Markdown(proposal: .init(proposal))) {
                    // Item View（セル）
                    ProposalItemView(proposal: proposal)
                }
            }
        }
        .tint(.darkText.opacity(0.2))
        .animation(.default, value: status)
        .navigationTitle("Swift Evolution")
        .onAppear(perform: selectFirstItem)
    }

    func selectFirstItem() {
#if os(macOS)
        if selection == nil, let proposal = proposals.first {
            selection = Markdown(proposal: .init(proposal))
        }
#elseif os(iOS)
        /// SplitView　が画面分割表示の場合に、初期表示を与える
        if horizontal == .regular, selection == nil, let proposal = proposals.first {
            selection = Markdown(proposal: .init(proposal))
        }
#endif
    }
}

// MARK: - ItemView
private struct ProposalItemView: View {
    let proposal: ProposalObject

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            let label = label
            HStack {
                // ラベル
                Text(label.text)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .overlay {
                        if #available(iOS 26.0, *) {
                            ConcentricRectangle(corners: .fixed(8))
                                .stroke()
                        } else {
                            RoundedRectangle(cornerRadius: 4, style: .circular)
                                .stroke()
                        }
                    }
                    .foregroundStyle(label.color)
                // ブックマーク
                Image(systemName: "bookmark.fill")
                    .foregroundStyle(label.color)
                    .opacity(proposal.isBookmarked ? 1 : 0)
                    .animation(.default, value: proposal.isBookmarked)
            }
            // 本文
            Text(title)
                .lineLimit(nil) // macOS でこの指定が必須
        }
#if os(macOS)
        .padding(.top, 8)
        .padding(.leading, 4)
#endif
    }

    var label: (text: String, color: Color) {
        let state = proposal.state
        let text = state.map(String.init(describing:)) ?? proposal.status.state
        let color = state?.color ?? .gray
        return (text, color)
    }

    var title: AttributedString {
        let id = AttributedString(proposal.id, attributes: .init().foregroundColor(.secondary))
        let markdownTitle = try? AttributedString(markdown: proposal.title)
        let title = markdownTitle ?? AttributedString(proposal.title, attributes: .init().foregroundColor(.primary))
        return id + " " + title
    }
}

#if DEBUG
#Preview {
    PreviewContainer {
        ContentView()
    }
}
#endif
