import SwiftUI

struct BookmarkButton: View {
    @Binding var isBookmarked: Bool

    var body: some View {
        Button("Bookmark", systemImage: isBookmarked ? "bookmark.fill" : "bookmark") {
            withAnimation {
                isBookmarked.toggle()
            }
        }
        .animation(.default, value: isBookmarked)
    }

    var symbol: String {
        isBookmarked ? "bookmark.fill" : "bookmark"
    }
}

#Preview {
    BookmarkButton(isBookmarked: .constant(false))
}
