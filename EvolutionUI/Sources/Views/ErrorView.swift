import SwiftUI

public struct ErrorView: View {
    public var error: Error?
    public var retry: (() -> Void)?

    public init(error: Error? = nil, retry: (() -> Void)? = nil) {
        self.error = error
        self.retry = retry
    }

    public var body: some View {
        Group {
            if let error {
                ContentUnavailableView {
                    switch error {
                    case is URLError:
                        Label("Connection issue", systemImage: "wifi.slash")
                    default:
                        Label("Error", systemImage: "exclamationmark.triangle")
                    }
                } description: {
                    Text(error.localizedDescription)
                } actions: {
                    if let retry {
                        Button("再試行", action: retry)
                    }
                }
            }
        }
        .animation(.default, value: error as? NSError)
    }
}

extension ErrorView {
    public init(error: (any Error)? = nil, _ retry: Binding<UUID?>) {
        self.init(error: error) {
            retry.wrappedValue = UUID()
        }
    }
}

#Preview {
    let error = URLError(.notConnectedToInternet, userInfo: [
        NSLocalizedDescriptionKey: "インターネット接続がオフラインのようです。"
    ])
    return ErrorView(error: error, retry: { })
}
