import EvolutionCore
import Foundation
import SwiftData

// MARK: - ProposalObject

@Model
/// A persistent SwiftData model representing a Swift Evolution proposal.
public final class ProposalObject: CustomStringConvertible {
    #Unique<ProposalObject>([\.proposalID])

    /// The unique identifier of the proposal as provided by the API.
    @Attribute(.unique) public var proposalID: String = ""
    /// The URL pointing to the proposal details.
    public var link: String = ""
    /// The current review status of the proposal.
    public var status: Status = Status()
    /// Human-readable title of the proposal.
    public var title: String = ""
    /// Indicates whether the user has bookmarked this proposal.
    public var isBookmarked: Bool = false

    /// Creates a new instance with the specified properties.
    /// - Parameters:
    ///   - id: The proposal identifier.
    ///   - link: The proposal's URL.
    ///   - status: Current status information.
    ///   - title: Title text shown to users.
    ///   - isBookmarked: Whether the proposal is bookmarked by the user.
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

    /// Textual representation used for debugging.
    public var description: String {
        "#\(proposalID) 🍩\(status.state) 📝\(title)"
    }
}

extension ProposalObject {
    /// Converts the stored state code into a ``ProposalStatus`` enum.
    public var state: ProposalStatus? {
        ProposalStatus(rawValue: status.state)
    }

    /// Retrieves proposals from the remote repository and merges them into the model container.
    /// - Parameter container: The container used to persist the fetched proposals.
    public static func fetch(container: ModelContainer) async throws {
        let context = ModelContext(container)
        // Fetch proposals from the API.
        let values = try await ProposalRipository().fetch()
        try context.transaction {
            // Merge and save the results retrieved from the API.
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

    /// Returns the proposal with the specified identifier in the given context, if available.
    public static subscript(id: String, in context: ModelContext) -> ProposalObject? {
        let predicate = #Predicate<ProposalObject> {
            $0.proposalID == id
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try? context.fetch(descriptor).first
    }
}

extension ProposalObject {
    /// Convenience initializer to create an instance from a ``Proposal`` value.
    /// - Parameters:
    ///   - value: The proposal value object.
    ///   - isBookmarked: Indicates whether the proposal is bookmarked.
    public convenience init(value: Proposal, isBookmarked: Bool) {
        self.init(
            id: value.id,
            link: value.link,
            status: value.status,
            title: value.title,
            isBookmarked: isBookmarked
        )
    }

    /// Updates the stored properties to match the given ``Proposal`` value.
    fileprivate func update(with value: Proposal) {
        link = value.link
        status = value.status
        title = value.title
    }
}
