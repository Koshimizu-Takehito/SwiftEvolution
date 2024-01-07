import SwiftUI
import SwiftData

// MARK: - ListView
struct ProposalListView: View {
    @Binding var path: NavigationPath
    @Query private var proposals: [ProposalObject]

    init(path: Binding<NavigationPath>, states: Set<ProposalState>) {
        _path = path
        _proposals = ProposalObject.query(states: states)
    }

    var body: some View {
        List {
            ForEach(proposals) { proposal in
                NavigationLink(value: ProposalURL(proposal)) {
                    ProposalItemView(item: .init(proposal))
                }
            }
        }
        .navigationTitle("Swift Evolution")
    }
}

// MARK: - ItemView
private struct ProposalItemView: View {
    let item: Proposal
    var state: ProposalState? { item.state }

    var body: some View {
        VStack(alignment: .leading) {
            // ラベル
            if let state {
                Text(String(describing: state))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .overlay {
                        RoundedRectangle(cornerRadius: 4, style: .circular)
                            .stroke()
                    }
                    .foregroundStyle(state.color)
            }
            // 本文
            Text(item.id)
                .foregroundStyle(.secondary)
            + Text(" ")
            + Text(item.title)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    PreviewContainer {
        ContentView()
    }
}
