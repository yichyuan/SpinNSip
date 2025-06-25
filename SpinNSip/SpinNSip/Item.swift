//
//  Item.swift
//  SpinNSip
//
//  Created by Aiden on 2025/4/24.
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
