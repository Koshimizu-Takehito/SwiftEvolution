//
//  Item.swift
//  SwiftEvolutionApp
//
//  Created by Takehito Koshimizu on 2023/12/29.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
