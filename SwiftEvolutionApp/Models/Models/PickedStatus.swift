import SwiftUI
import Observation

/// 選択中のステータス
@Observable
final class PickedStatus {
    /// ステータスの一覧
    var all: [ProposalState] {
        ProposalState.allCases
    }

    /// 選択中のステータス
    private(set) var current: Set<ProposalState> {
        didSet {
            let encoder = JSONEncoder()
            let data = try? encoder.encode(current)
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
        self.current = options ?? Set(ProposalState.allCases)
    }

    /// 該当ステータスの選択状態
    func isOn(_ state: ProposalState) -> Binding<Bool> {
        Binding { [weak self] in
            self?.current.contains(state) ?? false
        } set: { [weak self] isOn in
            if isOn {
                self?.current.insert(state)
            } else {
                self?.current.remove(state)
            }
        }
    }

    /// すべてのステータスが選択されている場合に `true` を返す。
    func isAll() -> Bool {
        current == Set(ProposalState.allCases)
    }

    /// ステータスがいずれも選択されていない場合に `true` を返す。
    func isNone() -> Bool {
        current.isEmpty
    }

    /// すべてのステータスを選択する
    func selectAll() {
        current = Set(ProposalState.allCases)
    }

    /// すべてのステータスを非選択にする
    func deselectAll() {
        current = []
    }

    /// 選択中のステータスを返す
    func selected() -> [ProposalState] {
        all.filter(current.contains)
    }
}
