import SwiftUI

public struct CopiedHUD: View {
    var copied: CopiedCode?
    @State var size = CGSize(width: Double.infinity, height: .infinity)
    @State var backgroundSize = CGSize(width: Double.infinity, height: .infinity)

    public init(copied: CopiedCode? = nil) {
        self.copied = copied
    }

    public var body: some View {
        VStack(spacing: 0) {
            let imageEdge: CGFloat = min(backgroundSize.width / 3, backgroundSize.height / 3)
            Image(systemName: "checkmark.circle")
                .resizable()
                .scaledToFit()
                .font(.title3)
                .frame(maxWidth: imageEdge, maxHeight: imageEdge)
                .padding()
            Text(copied != nil ? "Copied!" : "")
                .font(.title)
                .fontWeight(.bold)
                .contentTransition(.opacity)
                .animation(.default, value: copied)
        }
        .onGeometryChange(for: CGSize.self, of: \.size) { size = $1 }
        .frame(maxWidth: size.width, maxHeight: size.height)
        .padding()
        .glassEffect(in: .rect(cornerRadius: 18))
        .opacity(copied != nil ? 1 : 0)
        .symbolRenderingMode(.hierarchical)
        .foregroundStyle(.tint)
        .symbolEffect(.bounce, value: copied)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onGeometryChange(for: CGSize.self, of: \.size) {
            backgroundSize = $1
        }
    }
}
