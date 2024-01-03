import SwiftUI
import Observation

struct ProposalStatePicker: View {
    @State private var showPopover = false
    @Environment(ProposalStateOptions.self) private var model

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
                    ForEach(model.allOptions, id: \.self) { option in
                        Toggle(option.description, isOn: model.isOn(option))
                            .toggleStyle(.button)
                            .tint(option.color)
                    }
                }
                Divider()
                    .padding(.vertical)
                HStack {
                    Spacer()
                    Button("Select All") {
                        model.selectAllOptions()
                    }
                    .disabled(model.allOptionsSelected())
                    Spacer()
                    Button("Deselect All") {
                        model.deselectAllOptions()
                    }
                    .disabled(model.allOptionsDeselected())
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
        model.allOptionsSelected()
            ? "line.3.horizontal.decrease.circle"
            : "line.3.horizontal.decrease.circle.fill"
    }
}

#Preview {
    ProposalStatePicker()
        .environment(ProposalStateOptions())
}
