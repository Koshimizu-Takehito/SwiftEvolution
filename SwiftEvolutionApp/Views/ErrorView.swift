import SwiftUI

struct ErrorView: View {
    var error: Error
    var retry: (() -> Void)?

    var body: some View {
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

#Preview {
    let error = URLError(.notConnectedToInternet, userInfo: [
        NSLocalizedDescriptionKey: "インターネット接続がオフラインのようです。"
    ])
    return ErrorView(error: error, retry: { })
}
