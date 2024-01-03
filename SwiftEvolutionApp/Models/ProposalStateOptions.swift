import SwiftUI
import Observation

@Observable
final class ProposalStateOptions {
    var allOptions: [ProposalState] {
        ProposalState.allCases
    }

    var allOptionsSelected: Bool {
        options.allSatisfy { $1 }
    }

    private var options: [ProposalState: Bool] {
        didSet {
            let encoder = JSONEncoder()
            let data = try? encoder.encode(options)
            let defaults = UserDefaults.standard
            let key = String(describing: Self.self)
            defaults.set(data, forKey: key)
        }
    }

    init() {
        let defaults = UserDefaults.standard
        let key = String(describing: Self.self)
        let data = defaults.object(forKey: key) as? Data
        let options = data.flatMap { data in
            let decoder = JSONDecoder()
            return try? decoder.decode([ProposalState: Bool].self, from: data)
        }
        self.options = options ?? .init(
            uniqueKeysWithValues: ProposalState.allCases.map { ($0, true) }
        )
    }

    func isOn(_ state: ProposalState) -> Binding<Bool> {
        Binding { [options] in
            options[state, default: true]
        } set: { [weak self] isOn in
            self?.options[state] = isOn
        }
    }

    func selectAllOptions() {
        self.options = .init(
            uniqueKeysWithValues: ProposalState.allCases.map { ($0, true) }
        )
    }
}
