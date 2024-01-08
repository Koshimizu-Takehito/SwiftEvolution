import SwiftUI
import SwiftData

/// A view that creates a model container before showing preview content.
///
/// Use this view type only for previews, and only when you need
/// to create a container before showing the view content.
struct PreviewContainer<Content: View>: View {
    var content: () -> Content
    let container: ModelContainer

    init(
        _ container: @escaping () throws -> ModelContainer = PreviewSampleData.inMemoryContainer,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        do {
            self.container = try MainActor.assumeIsolated(container)
        } catch {
            fatalError("Failed to create the model container: \(error.localizedDescription)")
        }
    }

    var body: some View {
        content()
            .environment(PickedStates())
            .modelContainer(container)
    }
}
