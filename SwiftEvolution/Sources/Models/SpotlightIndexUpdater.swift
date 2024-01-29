import CoreSpotlight
import UniformTypeIdentifiers

actor SpotlightIndexUpdater {
    static func perform(values: [Proposal]) async throws {
        guard let bundleId = Bundle.main.bundleIdentifier else {
            return
        }
        let index = CSSearchableIndex(name: bundleId)
        var items = [CSSearchableItem]()
        for value in values {
            let uniqueId = "\(bundleId).\(value.id)"
            let attributes = CSSearchableItemAttributeSet(itemContentType: UTType.text.identifier)
            attributes.title = value.id
            attributes.contentDescription = value.title
            attributes.keywords = [value.id, value.id.replacing("-", with: ""), value.title]
            items.append(CSSearchableItem(
                uniqueIdentifier: uniqueId, domainIdentifier: bundleId, attributeSet: attributes
            ))
        }
        index.beginBatch()
        try await index.indexSearchableItems(items)
        try await index.endBatch(withClientState: Data())
    }
}
