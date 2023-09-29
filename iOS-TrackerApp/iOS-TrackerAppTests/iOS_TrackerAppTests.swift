//
//  iOS_TrackerAppTests.swift
//  iOS-TrackerAppTests
//
//  Created by Andy Kruch on 26.09.23.
//

import XCTest
import SnapshotTesting
@testable import iOS_TrackerApp


final class iOS_TrackerAppTests: XCTestCase {

    func testTrackersViewControllerSnapshot() throws {
        let vc = TrackersViewController(trackerStore: StubTrackerStore())
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testTrackersViewControllerDarkSnapshot() throws {
        let vc = TrackersViewController(trackerStore: StubTrackerStore())
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}

extension iOS_TrackerAppTests {
    private struct StubTrackerStore: TrackerStoreProtocol {
        var delegate: TrackerStoreDelegate?
        
        var numberOfTrackers: Int = 3
        var numberOfSections: Int = 2
        
        private static let category = TrackerCategory(label: "Обучение")
        private static let trackers: [[Tracker]] = [
            [
                Tracker(
                    label: "Программирование",
                    emoji: "🙂",
                    color: .bunchOfSChoices[safe: 16]!,
                    category: category,
                    isPinned: true,
                    daysCount: 5,
                    schedule: [.saturday]
                )
            ],
            [
                Tracker(
                    label: "Английский язык",
                    emoji: "🤔",
                    color: .bunchOfSChoices[safe: 14]!,
                    category: category,
                    isPinned: false,
                    daysCount: 1,
                    schedule: nil
                ),
                Tracker(
                    label: "Стрельба из лука",
                    emoji: "😪",
                    color: .bunchOfSChoices[safe: 9]!,
                    category: category,
                    isPinned: false,
                    daysCount: 2,
                    schedule: nil
                )
            ]
        ]
                
        func numberOfRowsInSection(_ section: Int) -> Int {
            switch section {
            case 0: return 1
            case 1: return 2
            default: return 0
            }
        }
        
        func headerLabelInSection(_ section: Int) -> String? {
            switch section {
            case 0: return "Закрепленные"
            case 1: return StubTrackerStore.category.label
            default: return nil
            }
        }
        
        func tracker(at indexPath: IndexPath) -> Tracker? {
            let tracker = StubTrackerStore.trackers[indexPath.section][indexPath.item]
            return tracker
        }
        
        func addTracker(_ tracker: Tracker, with category: TrackerCategory) throws {}
        func updateTracker(_ tracker: Tracker, with data: Tracker.Data) throws {}
        func deleteTracker(_ tracker: Tracker) throws {}
        func togglePin(for tracker: Tracker) throws {}
        func loadFilteredTrackers(date: Date, searchString: String) throws {}
    }
}


