//
//  Weekdays.swift
//  iOS-TrackerApp
//
//  Created by Andy Kruch on 31.07.23.
//

import Foundation

import Foundation

enum WeekDay: String, CaseIterable, Comparable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    var shortForm: String {
        switch self {
        case .monday: return "mon".localized
        case .tuesday: return "tue".localized
        case .wednesday: return "wed".localized
        case .thursday: return "thu".localized
        case .friday: return "fri".localized
        case .saturday: return "sat".localized
        case .sunday: return "sun".localized
        }
    }
    
    var fullName: String {
        switch self {
        case .monday: return "monday".localized
        case .tuesday: return "tuesday".localized
        case .wednesday: return "wednesday".localized
        case .thursday: return "thursday".localized
        case .friday: return "friday".localized
        case .saturday: return "saturday".localized
        case .sunday: return "sunday".localized
        }
    }
    
    static func < (lhs: WeekDay, rhs: WeekDay) -> Bool {
        guard
            let first = Self.allCases.firstIndex(of: lhs),
            let second = Self.allCases.firstIndex(of: rhs)
        else { return false }
        
        return first < second
    }
}

extension WeekDay {
    static func code(_ weekdays: [WeekDay]?) -> String? {
        guard let weekdays else { return nil }
        let indexes = weekdays.map { Self.allCases.firstIndex(of: $0) }
        var result = ""
        for i in 0..<7 {
            if indexes.contains(i) {
                result += "1"
            } else {
                result += "0"
            }
        }
        return result
    }
    
    static func decode(from string: String?) -> [WeekDay]? {
        guard let string else { return nil }
        var weekdays = [WeekDay]()
        for (index, value) in string.enumerated() {
            guard value == "1" else { continue }
            let weekday = Self.allCases[index]
            weekdays.append(weekday)
        }
        return weekdays
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
