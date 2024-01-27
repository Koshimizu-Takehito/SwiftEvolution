import SwiftUI
import Observation

struct ProposalStatusPicker: View {
    @State private var showPopover = false
    @SceneStorage var status: Set<ProposalStatus> = .allCases

    var body: some View {
        Button(
            action: {
                showPopover.toggle()
            },
            label: {
                Image(systemName: iconName)
                    .imageScale(.large)
            }
        )
        .popover(isPresented: $showPopover) {
            VStack {
                FlowLayout(alignment: .leading, spacing: 8) {
                    ForEach(ProposalStatus.allCases, id: \.self) { option in
                        Toggle(option.description, isOn: $status.isOn(option))
                            .toggleStyle(.button)
                            .tint(option.color)
                    }
                }
                Divider()
                    .padding(.vertical)
                HStack {
                    Spacer()
                    Button("Select All") {
                        status = Set(ProposalStatus.allCases)
                    }
                    .disabled(status == Set(ProposalStatus.allCases))
                    Spacer()
                    Button("Deselect All") {
                        status = []
                    }
                    .disabled(status.isEmpty)
                    Spacer()
                }
            }
            .frame(idealWidth: 240)
            .padding()
            .presentationCompactAdaptation(.popover)
            .tint(Color.blue)
        }
    }

    var iconName: String {
        status == Set(ProposalStatus.allCases)
            ? "line.3.horizontal.decrease.circle"
            : "line.3.horizontal.decrease.circle.fill"
    }
}

#Preview {
    ProposalStatusPicker()
}
