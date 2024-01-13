import SwiftUI

struct BookmarkButton: View {
    @Binding var isBookmarked: Bool

    var body: some View {
        Button(
            action: {
                withAnimation { isBookmarked.toggle() }
            },
            label: {
                Image(systemName: symbol)
                    .imageScale(.large)
            }
        )
        .animation(.default, value: isBookmarked)
    }

    var symbol: String {
        isBookmarked ? "bookmark.fill" : "bookmark"
    }
}

#Preview {
    @State var isBookmarked = false
    return BookmarkButton(isBookmarked: .constant(false))
}
