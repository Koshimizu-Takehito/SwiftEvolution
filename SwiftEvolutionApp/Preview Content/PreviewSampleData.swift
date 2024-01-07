import SwiftData
import SwiftUI

actor PreviewSampleData {
    @MainActor
    static var container: ModelContainer = {
        return try! inMemoryContainer()
    }()

    static var inMemoryContainer: () throws -> ModelContainer = {
        let schema = Schema([ProposalObject.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        let sampleData: [any PersistentModel] = [
        ]
        Task { @MainActor in
            sampleData.forEach {
                container.mainContext.insert($0)
            }
        }
        return container
    }
}

extension ProposalURL {
    static var fake0418: ProposalURL {
        ProposalURL(
            Proposal(
                id: "SE-0418",
                authors: [],
                link: "0418-inferring-sendable-for-methods.md",
                reviewManager: ReviewManager(
                    link: "https://github.com/kavon",
                    name: "Kavon Farvardin"
                ),
                sha: "9c423fd798382bcb5260aa9b473bd5d351acacd1",
                status: Status(state: ".accepted"),
                summary: "",
                title: "Inferring Sendable for methods and key path literals"
            )
        )
    }
}

extension Binding<NavigationPath> {
    static var fake: Self {
        .constant(Value())
    }
}

extension Binding where Value: ExpressibleByNilLiteral {
    static var fake: Self {
        .constant(nil)
    }
}
