import SwiftUI

extension AppStorage where Value == SyntaxHighlight {
    init(wrappedValue: Value, store: UserDefaults? = nil) {
        self.init(
            wrappedValue: wrappedValue,
            String(describing: Value.self),
            store: store
        )
    }
}
