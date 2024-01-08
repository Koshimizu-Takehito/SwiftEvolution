import SwiftUI
import SwiftData

// MARK: - ListView
struct ProposalListView: View {
    @Binding var detailURL: ProposalURL?
    @Query private var proposals: [ProposalObject]
    let states: Set<ProposalState>

    init(
        detailURL: Binding<ProposalURL?>,
        states: Set<ProposalState>,
        isBookmarked: Bool
    ) {
        self.states = states
        _detailURL = detailURL
        _proposals = ProposalObject.query(
            states: states, isBookmarked: isBookmarked
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
        .animation(.default, value: states)
        .navigationTitle("Swift Evolution")
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
                if proposal.isBookmarked {
                    Image(systemName: "bookmark.fill")
                        .foregroundStyle(label.color)
                }
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
