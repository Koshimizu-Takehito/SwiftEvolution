import EvolutionCore
import EvolutionModel
import EvolutionUI
import SwiftData
import SwiftUI

extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor public static var proposal: Self = .modifier(ProposalPreviewModifier())
}

struct ProposalPreviewModifier: PreviewModifier {
    public static func makeSharedContext() throws -> ModelContainer {
        let container = try ModelContainer(
            for: ProposalObject.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let mainContext = container.mainContext
        try mainContext.transaction {
            mainContext.insert(ProposalObject.init(value: .fake0418, isBookmarked: true))
            mainContext.insert(ProposalObject.init(value: .fake0465, isBookmarked: true))
        }
        return container
    }

    public func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
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
