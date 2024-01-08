import SwiftUI
import Observation

struct ProposalStatePicker: View {
    @State private var showPopover = false
    @Environment(PickedStates.self) private var model

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
                    ForEach(model.all, id: \.self) { option in
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
                        model.selectAll()
                    }
                    .disabled(model.isAll())
                    Spacer()
                    Button("Deselect All") {
                        model.deselectAll()
                    }
                    .disabled(model.isNone())
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
        model.isAll()
            ? "line.3.horizontal.decrease.circle"
            : "line.3.horizontal.decrease.circle.fill"
    }
}

#Preview {
    ProposalStatePicker()
        .environment(PickedStates())
}
