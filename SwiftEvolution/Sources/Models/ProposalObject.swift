import SwiftUI
import SwiftData

typealias ProposalID = String
typealias ProposalLink = String

// MARK: - ProposalObject
@Model
final class ProposalObject: CustomStringConvertible, @unchecked Sendable {
    #Unique<ProposalObject>([\.id])
    @Attribute(.unique) var id: ProposalID = ""
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

    var description: String {
        "#\(id) 🍩\(status.state) 📝\(title)"
    }
}

extension ProposalObject {
    var state: ProposalStatus? {
        ProposalStatus(rawValue: status.state)
    }

    @MainActor
    static func fetch(context: ModelContext) async throws {
        // APIからプロポーザルを取得
        let values = try await ProposalRipository().fetch()
        try context.transaction {
            // APIから取得した結果をマージ・保存
            let objects = Dictionary(
                try context.fetch(ProposalObject.self).lazy.map { ($0.id, $0) },
                uniquingKeysWith: { _, rhs in rhs }
            )
            values.forEach { value in
                let isBookmarked = objects[value.id]?.isBookmarked ?? false
                let object = ProposalObject(value: value, isBookmarked: isBookmarked)
                context.insert(object)
            }
        }
    }

    static subscript(id: ProposalID, in context: ModelContext) -> ProposalObject? {
        let predicate = #Predicate<ProposalObject> {
            $0.id == id
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try? context.fetch(descriptor).first
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

extension Query<ProposalObject, [ProposalObject]> {
    static func query(status: Set<ProposalStatus>, isBookmarked: Bool) -> Query {
        Query(
            filter: .predicate(states: status, isBookmarked: isBookmarked),
            sort: \.id,
            order: .reverse,
            animation: .default
        )
    }
}

extension Predicate<ProposalObject> {
    static func predicate(states: Set<ProposalStatus>, isBookmarked: Bool) -> Predicate<ProposalObject> {
        let states = Set(states.map(\.rawValue))
        return #Predicate { proposal in
            states.contains(proposal.status.state)
                && (!isBookmarked || proposal.isBookmarked == isBookmarked)
        }
    }

    static var bookmark: Predicate<ProposalObject> {
        #Predicate { $0.isBookmarked }
    }
}

extension ModelContext {
    func fetch<T>(_ type: T.Type = T.self) throws -> [T] where T : PersistentModel {
        try fetch(FetchDescriptor())
    }
}

extension KeyPath: @unchecked @retroactive Sendable where Root: Sendable, Value: Sendable {
}
