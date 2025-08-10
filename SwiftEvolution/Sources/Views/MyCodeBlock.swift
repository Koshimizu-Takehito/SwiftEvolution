import MarkdownUI
import Splash
import SwiftUI

struct MyCodeBlock: View {
    /// ColorScheme
    @Environment(\.colorScheme) private var colorScheme

    var configuration: CodeBlockConfiguration

    private var theme: Splash.Theme {
        // NOTE: We are ignoring the Splash theme font
        switch colorScheme {
        case .dark:
            return .wwdc18(withFont: .init(size: 16))
        default:
            return .sunset(withFont: .init(size: 16))
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView()

            Divider()

            ScrollView(.horizontal) {
                configuration.label
                    .relativeLineSpacing(.em(0.25))
                    .markdownTextStyle {
                        FontFamilyVariant(.monospaced)
                        FontSize(.em(0.85))
                    }
                    .padding()
            }
        }
        .background {
            Color(.secondarySystemBackground)
        }
        .clipShape(.rect(cornerRadius: 8))
        .markdownMargin(top: .zero, bottom: .em(0.8))
    }

    @ViewBuilder
    func headerView() -> some View {
        HStack {
            Text(configuration.language ?? "plain text")
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.semibold)
                .foregroundStyle(Color(theme.plainTextColor))
            Spacer()

            Image(systemName: "clipboard")
                .onTapGesture {
                    copyToClipboard(configuration.content)
                }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background {
            Color(theme.backgroundColor)
        }
    }

    private func copyToClipboard(_ string: String) {
        #if os(macOS)
            if let pasteboard = NSPasteboard.general {
                pasteboard.clearContents()
                pasteboard.setString(string, forType: .string)
            }
        #elseif os(iOS)
            UIPasteboard.general.string = string
        #endif
    }
}
