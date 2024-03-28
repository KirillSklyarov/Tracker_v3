//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 13.03.2024.
//

import Foundation

struct TrackerCategory {
    let header: String
    let trackers: [Tracker]
}

extension TrackerCategory {
    init(coreDataObject: TrackerCategoryCoreData) {
        self.header = coreDataObject.header ?? ""
        
        if let trackersSet = coreDataObject.trackers as? Set<TrackerCoreData> {
            self.trackers = trackersSet.map { Tracker(coreDataObject: $0) }
        } else {
            self.trackers = []
        }
    }
}
