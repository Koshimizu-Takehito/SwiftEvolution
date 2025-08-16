import EvolutionCore
import Foundation
import SwiftData

// MARK: - ProposalObject

@Model
public final class ProposalObject: CustomStringConvertible {
    #Unique<ProposalObject>([\.proposalID])

    @Attribute(.unique) public var proposalID: String = ""
    public var link: String = ""
    public var status: Status = Status()
    public var title: String = ""
    public var isBookmarked: Bool = false

    public init(
        id: String,
        link: String,
        status: Status,
        title: String,
        isBookmarked: Bool
    ) {
        self.proposalID = id
        self.link = link
        self.status = status
        self.title = title
        self.isBookmarked = isBookmarked
    }

    public var description: String {
        "#\(proposalID) 🍩\(status.state) 📝\(title)"
    }
}

extension ProposalObject {
    public var state: ProposalStatus? {
        ProposalStatus(rawValue: status.state)
    }

    public static func fetch(container: ModelContainer) async throws {
        let context = ModelContext(container)
        // APIからプロポーザルを取得
        let values = try await ProposalRipository().fetch()
        try context.transaction {
            // APIから取得した結果をマージ・保存
            let objects = Dictionary(
                try context.fetch(FetchDescriptor<ProposalObject>()).lazy.map {
                    ($0.proposalID, $0)
                },
                uniquingKeysWith: { _, rhs in rhs }
            )
            values.forEach { value in
                let isBookmarked = objects[value.id]?.isBookmarked ?? false
                let object = ProposalObject(value: value, isBookmarked: isBookmarked)
                context.insert(object)
            }
        }
    }

    public static subscript(id: String, in context: ModelContext) -> ProposalObject? {
        let predicate = #Predicate<ProposalObject> {
            $0.proposalID == id
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try? context.fetch(descriptor).first
    }
}

extension ProposalObject {
    public convenience init(value: Proposal, isBookmarked: Bool) {
        self.init(
            id: value.id,
            link: value.link,
            status: value.status,
            title: value.title,
            isBookmarked: isBookmarked
        )
    }

    fileprivate func update(with value: Proposal) {
        link = value.link
        status = value.status
        title = value.title
    }
}
