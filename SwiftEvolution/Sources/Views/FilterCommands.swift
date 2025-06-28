//
//  FilterCommands.swift
//  SwiftEvolution
//
//  Created by Takehito Koshimizu on 2025/06/28.
//

import SwiftUI

struct FilterCommands: Commands {
    @AppStorage var status: Set<ProposalStatus> = .allCases
    @AppStorage("isBookmarked") private var isBookmarked: Bool = false

    var body: some Commands {
        CommandMenu("フィルタ") {
            Divider()
            Menu("レビューの状態") {
                ForEach(0..<3, id: \.self) { index in
                    let option = ProposalStatus.allCases[index]
                    Toggle(option.description, isOn: $status.isOn(option))
                        .keyboardShortcut(.init(Character("\(index + 1)")), modifiers: [.command])
                }

                Divider()

                Button("すべて選択する") {
                    status = Set(ProposalStatus.allCases)
                }
                .disabled(status == Set(ProposalStatus.allCases))
                .keyboardShortcut("A", modifiers: [.command, .shift])

                Button("すべて非選択にする") {
                    status = []
                }
                .disabled(status.isEmpty)
                .keyboardShortcut("D", modifiers: [.command, .shift])
            }
            Divider()

            Toggle("ブックマークのみ表示する", isOn: $isBookmarked)
                .keyboardShortcut("B", modifiers: [.command, .shift])
        }
    }
}
