import SwiftUI
import SwiftData

/// A view that creates a model container before showing preview content.
///
/// Use this view type only for previews, and only when you need
/// to create a container before showing the view content.
struct PreviewContainer<Content: View>: View {
    var content: (_ context: ModelContext) -> Content
    let modelContainer: ModelContainer

    init(
        _ modelContainer: @escaping () throws -> ModelContainer = PreviewSampleData.inMemoryContainer,
        @ViewBuilder content: @escaping (_ context: ModelContext) -> Content
    ) {
        self.content = content
        do {
            self.modelContainer = try MainActor.assumeIsolated(modelContainer)
        } catch {
            fatalError("Failed to create the model container: \(error.localizedDescription)")
        }
    }

    var body: some View {
        content(modelContainer.mainContext)
            .modelContainer(modelContainer)
    }
}
