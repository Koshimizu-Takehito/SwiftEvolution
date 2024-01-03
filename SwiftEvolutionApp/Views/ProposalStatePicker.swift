import SwiftUI
import Observation

@Observable
final class ProposalStateSetting {
    var selected: [ProposalState: Bool] = [:]
}

struct ProposalStatePicker: View {
    private let states = ProposalState.allCases
    @State private var showPopover = false

    var body: some View {
        Button("Show Popover") {
            showPopover.toggle()
        }
        .popover(isPresented: $showPopover) {
            FlowLayout(alignment: .leading, spacing: 8) {
                ForEach(states, id: \.self) { keyword in
                    Text(keyword.description)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 12)
                        .background(Color(.systemGroupedBackground))
                        .cornerRadius(15)
                }
            }
            .frame(idealWidth: 240)
            .padding()
            .presentationCompactAdaptation(.popover)
        }
    }
}

#Preview {
    ProposalStatePicker()
}
