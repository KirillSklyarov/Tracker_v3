//
//  TrackerModel.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 13.03.2024.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: String
    let emoji: String
    let schedule: String
}

extension Tracker {
    init(coreDataObject: TrackerCoreData) {
        self.id = coreDataObject.id  ?? UUID()
        self.name = coreDataObject.name ?? ""
        self.color = coreDataObject.colorHex ?? "#000000"
        self.emoji = coreDataObject.emoji ?? ""
        self.schedule = coreDataObject.schedule ?? ""
    }
}
