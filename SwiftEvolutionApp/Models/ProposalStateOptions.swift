import SwiftUI
import Observation

@Observable
final class ProposalStateOptions {
    /// すべての選択肢
    var allOptions: [ProposalState] {
        ProposalState.allCases
    }

    private(set) var values: [ProposalState: Bool] {
        didSet {
            let encoder = JSONEncoder()
            let data = try? encoder.encode(values)
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
        self.values = options ?? .init(
            uniqueKeysWithValues: ProposalState.allCases.map { ($0, true) }
        )
    }

    /// 該当の選択肢の選択状態
    func isOn(_ state: ProposalState) -> Binding<Bool> {
        Binding { [values] in
            values[state, default: true]
        } set: { [weak self] isOn in
            self?.values[state] = isOn
        }
    }

    /// すべての選択肢が選択されている場合に `true` を返す。
    func allOptionsSelected() -> Bool {
        values.allSatisfy { $1 }
    }

    /// 選択肢がいずれも選択されていない場合に `true` を返す。
    func allOptionsDeselected() -> Bool {
        values.allSatisfy { !$1 }
    }

    /// すべての選択肢を選択する
    func selectAllOptions() {
        self.values = .init(
            uniqueKeysWithValues: allOptions.map { ($0, true) }
        )
    }

    /// すべての選択肢を非選択にする
    func deselectAllOptions() {
        self.values = .init(
            uniqueKeysWithValues: allOptions.map { ($0, false) }
        )
    }

    /// 選択中の選択肢を返す
    func selectedOptions() -> [ProposalState] {
        allOptions.filter { state in
            values[state, default: false]
        }
    }
}
