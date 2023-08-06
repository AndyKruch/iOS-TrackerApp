//
//  TrackerCategory.swift
//  iOS-TrackerApp
//
//  Created by Andy Kruch on 31.07.23.
//

import UIKit

struct TrackerCategory {
    let label: String
    let trackers: [Tracker]
    
    init(label: String, trackers: [Tracker]) {
        self.label = label
        self.trackers = trackers
    }
}
