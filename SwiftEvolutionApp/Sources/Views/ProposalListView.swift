import SwiftUI
import SwiftData

// MARK: - ListView
struct ProposalListView: View {
    let horizontal: UserInterfaceSizeClass?
    @Binding var detailURL: ProposalURL?
    @Query private var proposals: [ProposalObject]
    let status: Set<ProposalState>

    init(
        horizontal: UserInterfaceSizeClass?,
        detailURL: Binding<ProposalURL?>,
        status: Set<ProposalState>,
        isBookmarked: Bool
    ) {
        self.horizontal = horizontal
        self.status = status
        _detailURL = detailURL
        _proposals = ProposalObject.query(
            status: status, isBookmarked: isBookmarked
        )
    }

    var body: some View {
        List(selection: $detailURL) {
            ForEach(proposals) { proposal in
                NavigationLink(value: ProposalURL(proposal)) {
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
        /// SplitView　が画面分割表示の場合に、初期表示を与える
        if horizontal == .regular, detailURL == nil, let proposal = proposals.first {
            detailURL = ProposalURL(proposal)
        }
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
            Text(proposal.id)
                .foregroundStyle(.secondary)
            + Text(" ")
            + Text(proposal.title)
                .foregroundStyle(.primary)
        }
    }

    var label: (text: String, color: Color) {
        let state = proposal.state
        let text = state.map(String.init(describing:)) ?? proposal.status.state
        let color = state?.color ?? .gray
        return (text, color)
    }
}

#Preview {
    PreviewContainer {
        ContentView()
    }
}
