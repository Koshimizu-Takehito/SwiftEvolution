import SwiftUI

extension SceneStorage where Value: RawRepresentable, Value.RawValue == String {
    public init(wrappedValue: Value) {
        self.init(wrappedValue: wrappedValue, String(describing: Value.self))
    }
}
