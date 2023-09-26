//
//  Tracker.swift
//  iOS-TrackerApp
//
//  Created by Andy Kruch on 31.07.23.
//

import UIKit

struct Tracker: Identifiable {
    let id: UUID
    let title: String
    let emoji: String
    let color: UIColor
    let category: TrackerCategory
    let isPinned: Bool
    let daysCount: Int
    let schedule: [WeekDay]?
    
    init(id: UUID = UUID(), label: String, emoji: String, color: UIColor, category: TrackerCategory, isPinned: Bool, daysCount: Int, schedule: [WeekDay]?) {
        self.id = id
        self.title = label
        self.emoji = emoji
        self.color = color
        self.category = category
        self.isPinned = isPinned
        self.daysCount = daysCount
        self.schedule = schedule
    }
    
    init(tracker: Tracker) {
        self.id = tracker.id
        self.title = tracker.title
        self.emoji = tracker.emoji
        self.color = tracker.color
        self.category = tracker.category
        self.isPinned = tracker.isPinned
        self.daysCount = tracker.daysCount
        self.schedule = tracker.schedule
    }
    
    init(data: Data) {
        guard let emoji = data.emoji, let color = data.color, let category = data.category else { fatalError() }
        
        self.id = UUID()
        self.title = data.label
        self.emoji = emoji
        self.color = color
        self.category = category
        self.isPinned = data.isPinned
        self.daysCount = data.daysCount
        self.schedule = data.schedule
    }
    
    var data: Data {
        Data(label: title, emoji: emoji, color: color, category: category, daysCount: daysCount, schedule: schedule)
    }
}

extension Tracker {
    struct Data {
        var label: String = ""
        var emoji: String? = nil
        var color: UIColor? = nil
        var category: TrackerCategory? = nil
        var isPinned: Bool = false
        var daysCount: Int = 0
        var schedule: [WeekDay]? = nil
    }
}
