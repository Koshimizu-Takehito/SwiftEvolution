//
//  RootView.swift
//  SwiftEvolutionApp
//
//  Created by Takehito Koshimizu on 2024/01/01.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        ContentView()
            .environment(ProposalList())
            .environment(ProposalStateOptions())
    }
}

#Preview {
    RootView()
}
