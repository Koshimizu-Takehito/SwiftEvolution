import SwiftUI
import Observation

@Observable
final class ProposalStateOptions {
    /// すべての選択肢
    var allOptions: [ProposalState] {
        ProposalState.allCases
    }

    private(set) var currentOption: Set<ProposalState> {
        didSet {
            let encoder = JSONEncoder()
            let data = try? encoder.encode(currentOption)
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
            return try? decoder.decode(Set<ProposalState>.self, from: data)
        }
        self.currentOption = options ?? Set(ProposalState.allCases)
    }

    /// 該当の選択肢の選択状態
    func isOn(_ state: ProposalState) -> Binding<Bool> {
        Binding { [weak self] in
            self?.currentOption.contains(state) ?? false
        } set: { [weak self] isOn in
            if isOn {
                self?.currentOption.insert(state)
            } else {
                self?.currentOption.remove(state)
            }
        }
    }

    /// すべての選択肢が選択されている場合に `true` を返す。
    func allOptionsSelected() -> Bool {
        currentOption == Set(ProposalState.allCases)
    }

    /// 選択肢がいずれも選択されていない場合に `true` を返す。
    func allOptionsDeselected() -> Bool {
        currentOption.isEmpty
    }

    /// すべての選択肢を選択する
    func selectAllOptions() {
        currentOption = Set(ProposalState.allCases)
    }

    /// すべての選択肢を非選択にする
    func deselectAllOptions() {
        currentOption = []
    }

    /// 選択中の選択肢を返す
    func selectedOptions() -> [ProposalState] {
        allOptions.filter { state in
            currentOption.contains(state)
        }
    }
}
