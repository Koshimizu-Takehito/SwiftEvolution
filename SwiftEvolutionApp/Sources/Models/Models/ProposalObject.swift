import SwiftUI
import SwiftData

typealias ProposalID = String
typealias ProposalLink = String

// MARK: - ProposalObject
@Model
final class ProposalObject {
    var id: ProposalID = ""
    var link: ProposalLink = ""
    var status: Status = Status()
    var title: String = ""
    var isBookmarked: Bool = false

    init(
        id: String,
        link: String,
        status: Status,
        title: String,
        isBookmarked: Bool
    ) {
        self.id = id
        self.link = link
        self.status = status
        self.title = title
        self.isBookmarked = isBookmarked
    }
}

extension ProposalObject {
    var state: ProposalState? {
        ProposalState(rawValue: status.state)
    }

    @MainActor
    static func fetch(context: ModelContext) async throws {
        // APIからプロポーザルを取得
        let values = try await Task.detached {
            let url = URL(string: "https://download.swift.org/swift-evolution/proposals.json")!
            let (data, _) = try await URLSession.shared.data(from: url)
            var values = try JSONDecoder().decode([Proposal].self, from: data)
            for (offset, proposal) in values.enumerated() {
                values[offset].title = proposal.title.trimmingCharacters(in: .whitespaces)
            }
            return values
        }.value

        // APIから取得した結果をマージ・保存
        let objects = Dictionary(
            self.objects(in: context).map { ($0.id, $0) },
            uniquingKeysWith: { _, rhs in rhs }
        )
        values.forEach { value in
            if let object = objects[value.id] {
                object.update(with: value)
            } else {
                let object = ProposalObject(value: value, isBookmarked: false)
                context.insert(object)
            }
        }
    }

    static func objects(in context: ModelContext) -> [ProposalObject] {
        (try? context.fetch(FetchDescriptor<ProposalObject>())) ?? []
    }

    static func find(by id: ProposalID, in context: ModelContext) -> ProposalObject? {
        let predicate = #Predicate<ProposalObject> {
            $0.id == id
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try? context.fetch(descriptor).first
    }

    static subscript(id: ProposalID, in context: ModelContext) -> ProposalObject? {
        let predicate = #Predicate<ProposalObject> {
            $0.id == id
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try? context.fetch(descriptor).first
    }

    static func query(status: Set<ProposalState>, isBookmarked: Bool) -> Query<ProposalObject, [ProposalObject]> {
        Query(
            filter: predicate(states: status, isBookmarked: isBookmarked),
            sort: \.id,
            order: .reverse,
            animation: .default
        )
    }

    static func predicate(states: Set<ProposalState>, isBookmarked: Bool) -> Predicate<ProposalObject> {
        let states = Set(states.map(\.rawValue))
        return #Predicate<ProposalObject> { proposal in
            states.contains(proposal.status.state)
                && (!isBookmarked || proposal.isBookmarked == isBookmarked)
        }
    }
}

private extension ProposalObject {
    convenience init(value: Proposal, isBookmarked: Bool) {
        self.init(
            id: value.id,
            link: value.link,
            status: value.status,
            title: value.title,
            isBookmarked: isBookmarked
        )
    }

    func update(with value: Proposal) {
        link = value.link
        status = value.status
        title = value.title
    }
}

extension Predicate<ProposalObject> {
    static var bookmark: Predicate<ProposalObject> {
        #Predicate<ProposalObject> { $0.isBookmarked }
    }
}
