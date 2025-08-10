import SwiftUI

struct CopiedHUD: View {
    var copied: CopiedCode?

    var body: some View {
        if copied != nil {
            VStack {
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .scaledToFit()
                    .font(.title3)
                    .frame(maxWidth: 120, maxHeight: 120)
                Text("Copied!")
                    .font(.title.bold())
                    .minimumScaleFactor(0.1)
            }
            .frame(width: 180, height: 180)
            .padding()
            .background(.ultraThinMaterial, in: .rect)
            .clipShape(.rect(cornerRadius: 12))
            .transition(.opacity)
        }
    }
}
