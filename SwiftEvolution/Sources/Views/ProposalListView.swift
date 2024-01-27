import SwiftUI
import SwiftData

// MARK: - ListView
struct ProposalListView: View {
    let horizontal: UserInterfaceSizeClass?
    @Binding var selection: Markdown?
    @Query private var proposals: [ProposalObject]
    let status: Set<ProposalState>

    init(
        horizontal: UserInterfaceSizeClass?,
        selection: Binding<Markdown?>,
        status: Set<ProposalState>,
        isBookmarked: Bool
    ) {
        self.horizontal = horizontal
        self.status = status
        _selection = selection
        _proposals = ProposalObject.query(
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
        VStack(alignment: .leading) {
            let label = label
            HStack {
                // ラベル
                Text(label.text)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .overlay {
                        RoundedRectangle(cornerRadius: 4, style: .circular)
                            .stroke()
                    }
                    .foregroundStyle(label.color)
                // ブックマーク
                Image(systemName: "bookmark.fill")
                    .foregroundStyle(label.color)
                    .opacity(proposal.isBookmarked ? 1 : 0)
                    .animation(.default, value: proposal.isBookmarked)
            }
            // 本文
            let text = Text(proposal.id)
                .foregroundStyle(.secondary)
            + Text(" ")
            + Text(proposal.title)
                .foregroundStyle(.primary)
            text
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
}

#if DEBUG
#Preview {
    PreviewContainer {
        ContentView()
    }
}
#endif
