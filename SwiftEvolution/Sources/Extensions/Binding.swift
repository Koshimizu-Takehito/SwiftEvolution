import SwiftUI

extension Binding<Set<ProposalStatus>> {
    func isOn(_ state: ProposalStatus) -> Binding<Bool> {
        Binding<Bool> {
            wrappedValue.contains(state)
        } set: { isOn in
            if isOn {
                wrappedValue.insert(state)
            } else {
                wrappedValue.remove(state)
            }
        }
    }
}
