import Markdown
import MarkdownUI
import Splash
import SwiftData
import SwiftUI

@MainActor
extension BlockStyle where Configuration == ListMarkerConfiguration {
    public static var customCircle: Self {
        BlockStyle { _ in
            Circle()
                .frame(width: 6, height: 6)
                .relativeFrame(minWidth: .zero, alignment: .trailing)
        }
    }

    public static var customDecimal: Self {
        BlockStyle { configuration in
            Text("\(configuration.itemNumber).")
                .monospacedDigit()
                .relativeFrame(minWidth: .zero, alignment: .trailing)
        }
    }
}
