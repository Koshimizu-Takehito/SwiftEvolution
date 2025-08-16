import SwiftData
import SwiftUI

@MainActor
final class PreviewSampleData {
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

extension Proposal {
    static var fake0418: Self {
        Proposal(
            id: "SE-0418",
            link: "0418-inferring-sendable-for-methods.md",
            status: Status(state: ".accepted"),
            title: "Inferring Sendable for methods and key path literals"
        )
    }

    static var fake0465: Self {
        Proposal(
            id: "SE-0465",
            link: "0465-nonescapable-stdlib-primitives.md",
            status: Status(state: ".implemented"),
            title: "Standard Library Primitives for Nonescapable Types"
        )
    }
}

extension Markdown {
    static var fake0418: Self {
        Markdown(proposal: .fake0418, url: nil)
    }

    static var fake0465: Self {
        Markdown(proposal: .fake0465, url: nil)
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
