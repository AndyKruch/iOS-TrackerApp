//
//  TrackerRecord.swift
//  iOS-TrackerApp
//
//  Created by Andy Kruch on 31.07.23.
//

import Foundation

struct TrackerRecord: Hashable {
    let id: UUID
    let trackerId: UUID
    let date: Date
    
    init(id: UUID = UUID(), trackerId: UUID, date: Date) {
        self.id = id
        self.trackerId = trackerId
        self.date = date
    }
}
