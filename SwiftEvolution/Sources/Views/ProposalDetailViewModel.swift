import Foundation
import Markdown
import Observation
import SwiftData

import struct SwiftUI.Color

@Observable
@MainActor
final class ProposalDetailViewModel: Observable {
    /// 当該コンテンツ
    private(set) var markdown: Markdown {
        didSet {
            items = .init(markdown: markdown)
        }
    }
    /// 表示用のコンテンツ
    private(set) var items: [ProposalDetailRow] = []
    /// マークダウン取得エラー
    private(set) var fetcherror: Error?
    /// 翻訳中
    var translating: Bool = false

    /// 画面のタイトル
    var title: String {
        markdown.proposal.title
    }

    var tint: Color? {
        markdown.proposal.state?.color
    }

    /// ブックマークの状態
    var isBookmarked: Bool {
        get {
            ProposalObject[markdown.proposal.id, in: context]?.isBookmarked == true
        }
        set {
            save(isBookmarked: newValue)
        }
    }

    /// ModelContext
    @ObservationIgnored private let context: ModelContext

    init(markdown: Markdown, context: ModelContext) {
        self.markdown = markdown
        self.context = context
        Task {
            await fetchText()
        }
    }

    /// 当該プロポーザルのブックマークの有無を保存
    private func save(isBookmarked: Bool) {
        let proposal = ProposalObject[markdown.proposal.id, in: context]
        guard let proposal else { return }
        proposal.isBookmarked = isBookmarked
        try? proposal.modelContext?.save()
    }

    /// マークダウンテキストを取得
    func fetchText() async {
        fetcherror = nil
        do {
            markdown.text = try await markdown.fetch()
        } catch let error as URLError where error.code != URLError.cancelled {
            fetcherror = error
        } catch {
            fetcherror = error
        }
    }

    func translate() async throws {
        if let text = markdown.text {
            translating = true
            defer { translating = false }
            let translator = MarkdownTranslator()
            for try await result in await translator.translate(markdown: text) {
                guard markdown.text != result else {
                    continue
                }
                markdown.text = result
                await Task.yield()
            }
        }
    }

    /// Markdownのヘッダー行からHTMLのidスラッグを作る
    /// - Parameters:
    ///   - line: 例: "### `~Copyable` as logical negation"
    ///   - includeHash: 先頭に `#` を付ける（デフォルト true）
    /// - Returns: 例: "#copyable-as-logical-negation"
    nonisolated static func htmlID(fromMarkdownHeader line: String, includeHash: Bool = true) -> String {
        // 1) 先頭の見出しマーカーを除去（0〜3個の空白 + #1〜6 + 空白）
        let headerPattern = #"^\s{0,3}#{1,6}\s+"#
        let textStart = line.replacingOccurrences(
            of: headerPattern,
            with: "",
            options: .regularExpression
        )

        // 2) バッククォートとかっこを除去（中身は残す）
        var s = textStart.replacingOccurrences(of: "`", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")

        // 3) Unicode正規化（ローマ字化→ダイアクリティカル除去）
        //    例: "Café" -> "Cafe", 日本語は toLatin でローマ字化される場合あり
        if let latin = s.applyingTransform(.toLatin, reverse: false) {
            s = latin
        }
        s = s.folding(
            options: [.diacriticInsensitive, .caseInsensitive],
            locale: .current
        )

        // 4) 小文字化
        s = s.lowercased()

        // 5) 許可しない文字をハイフンに置換（英数以外はまとめて-）
        //    連続する非英数字は1つのハイフンに圧縮
        s = s.replacingOccurrences(
            of: #"[^a-z0-9]+"#,
            with: "-",
            options: .regularExpression
        )

        // 6) 前後のハイフンをトリム
        s = s.trimmingCharacters(in: CharacterSet(charactersIn: "-"))

        // 7) 空ならフォールバック
        if s.isEmpty { s = "section" }

        return includeHash ? "#\(s)" : s
    }
}

extension ProposalDetailViewModel {
    enum URLAction {
        case scrollTo(id: String)
        case showMarkdown(Markdown)
        case open(URL)
    }

    func makeURLAction(url: URL) -> URLAction {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return .open(url)
        }
        switch (components.scheme, components.host, components.path) {
        case (_, "github.com", let path):
            guard let match = path.firstMatch(of: /^.+\/swift-evolution\/.*\/(\d+)-.*\.md/) else {
                break
            }
            return makeMarkdown(id: match.1, url: url).map(URLAction.showMarkdown) ?? .open(url)

        case (nil, nil, "") where components.fragment?.isEmpty == false:
            return .scrollTo(id: url.absoluteString)

        case (nil, nil, let path):
            guard let match = path.firstMatch(of: /(\d+)-.*\.md$/) else {
                break
            }
            return makeMarkdown(id: match.1).map(URLAction.showMarkdown) ?? .open(url)

        default:
            break
        }
        return .open(url)
    }

    fileprivate func makeMarkdown(id: some StringProtocol, url: URL? = nil) -> Markdown? {
        let id = "SE-\(String(id))"
        let url = url.map(MarkdownURL.init(rawValue:))
        let context = context.container.mainContext
        guard let proposal = ProposalObject[id, in: context] else {
            return nil
        }
        return Markdown(proposal: .init(proposal), url: url)
    }
}
