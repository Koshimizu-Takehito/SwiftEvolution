import SwiftUI

/// A button that toggles the bookmark state for a proposal.
public struct BookmarkButton: View {
    /// Binding that reflects whether the proposal is bookmarked.
    @Binding var isBookmarked: Bool

    /// Creates a bookmark toggle bound to the given state.
    public init(isBookmarked: Binding<Bool>) {
        _isBookmarked = isBookmarked
    }

    public var body: some View {
        Button("Bookmark", systemImage: isBookmarked ? "bookmark.fill" : "bookmark") {
            withAnimation {
                isBookmarked.toggle()
            }
        }
        .animation(.default, value: isBookmarked)
    }

    /// The SF Symbol name for the current state.
    var symbol: String {
        isBookmarked ? "bookmark.fill" : "bookmark"
    }
}

#Preview {
    BookmarkButton(isBookmarked: .constant(false))
}
