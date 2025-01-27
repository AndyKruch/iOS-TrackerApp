//
//  TrackerStore.swift
//  iOS-TrackerApp
//
//  Created by Andy Kruch on 28.08.23.
//

import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate()
}

protocol TrackerStoreProtocol {
    var numberOfTrackers: Int { get }
    var numberOfSections: Int { get }
    var delegate: TrackerStoreDelegate? { get set}
    func numberOfRowsInSection(_ section: Int) -> Int
    func headerLabelInSection(_ section: Int) -> String?
    func tracker(at indexPath: IndexPath) -> Tracker?
    func addTracker(_ tracker: Tracker, with category: TrackerCategory) throws
    func updateTracker(_ tracker: Tracker, with data: Tracker.Data) throws
    func deleteTracker(_ tracker: Tracker) throws
    func togglePin(for tracker: Tracker) throws
    func loadFilteredTrackers(date: Date, searchString: String) throws
}

final class TrackerStore: NSObject {
    // MARK: - Properties
    weak var delegate: TrackerStoreDelegate?
    
    private let context: NSManagedObjectContext
    private let trackerCategoryStore = TrackerCategoryStore()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.category?.createdAt, ascending: true),
            NSSortDescriptor(keyPath: \TrackerCoreData.createdAt, ascending: true)
        ]
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category",
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    // MARK: - Lifecycle
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    // MARK: - Methods
    func makeTracker(from coreData: TrackerCoreData) throws -> Tracker {
        guard
            let idString = coreData.trackerId,
            let id = UUID(uuidString: idString),
            let label = coreData.label,
            let emoji = coreData.emoji,
            let colorHEX = coreData.colorHEX,
            let categoryCoreData = coreData.category,
            let category = try? trackerCategoryStore.makeCategory(from: categoryCoreData),
            let daysCount = coreData.records
        else { throw StoreError.decodeError }
        let color = ColorMarshalling.deserialize(hexString: colorHEX)
        let scheduleString = coreData.schedule
        let schedule = WeekDay.decode(from: scheduleString)
        return Tracker(
            id: id,
            label: label,
            emoji: emoji,
            color: color!,
            category: category,
            isPinned: coreData.isPinned,
            daysCount: daysCount.count,
            schedule: schedule
        )
    }
    
    func getTrackerCoreData(by id: UUID) throws -> TrackerCoreData? {
        fetchedResultsController.fetchRequest.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCoreData.trackerId), id.uuidString
        )
        try fetchedResultsController.performFetch()
        guard let tracker = fetchedResultsController.fetchedObjects?.first else { throw StoreError.fetchTrackerError }
        fetchedResultsController.fetchRequest.predicate = nil
        try fetchedResultsController.performFetch()
        return tracker
    }
    
    func loadFilteredTrackers(date: Date, searchString: String) throws {
        var predicates = [NSPredicate]()
        
        let weekdayIndex = Calendar.current.component(.weekday, from: date)
        let iso860WeekdayIndex = weekdayIndex > 1 ? weekdayIndex - 2 : weekdayIndex + 5
        
        var regex = ""
        for index in 0..<7 {
            if index == iso860WeekdayIndex {
                regex += "1"
            } else {
                regex += "."
            }
        }
        
        predicates.append(NSPredicate(
            format: "%K == nil OR (%K != nil AND %K MATCHES[c] %@)",
            #keyPath(TrackerCoreData.schedule),
            #keyPath(TrackerCoreData.schedule),
            #keyPath(TrackerCoreData.schedule), regex
        ))
        
        if !searchString.isEmpty {
            predicates.append(NSPredicate(
                format: "%K CONTAINS[CoreData] %@",
                #keyPath(TrackerCoreData.label), searchString
            ))
        }
        
        fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        try fetchedResultsController.performFetch()
        
        delegate?.didUpdate()
    }
}

extension TrackerStore {
    enum StoreError: Error {
        case decodeError, fetchTrackerError, deleteError, pinError
    }
}

// MARK: - TrackerStoreProtocol
extension TrackerStore: TrackerStoreProtocol {
    
    private var pinnedTrackers: [Tracker] {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else { return [] }
        let trackers = fetchedObjects.compactMap { try? makeTracker(from: $0) }
        return trackers.filter({ $0.isPinned })
    }
    
    private var sections: [[Tracker]] {
        guard let sectionsCoreData = fetchedResultsController.sections else { return [] }
        var sections: [[Tracker]] = []
        
        if !pinnedTrackers.isEmpty {
            sections.append(pinnedTrackers)
        }
        
        sectionsCoreData.forEach { section in
            var sectionToAdd = [Tracker]()
            section.objects?.forEach({ object in
                guard
                    let trackerCoreData = object as? TrackerCoreData,
                    let tracker = try? makeTracker(from: trackerCoreData),
                    !pinnedTrackers.contains(where: { $0.id == tracker.id })
                else { return }
                sectionToAdd.append(tracker)
            })
            if !sectionToAdd.isEmpty {
                sections.append(sectionToAdd)
            }
        }
        return sections
    }
    
    var numberOfTrackers: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    var numberOfSections: Int {
        sections.count
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        sections[section].count
    }
    
    func headerLabelInSection(_ section: Int) -> String? {
        if !pinnedTrackers.isEmpty && section == 0 {
            return NSLocalizedString("TrackerStore.pin", comment: "Pinned")
        }
        guard let category = sections[section].first?.category else { return nil }
        return category.label
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        let tracker = sections[indexPath.section][indexPath.item]
        return tracker
    }
    
    func addTracker(_ tracker: Tracker, with category: TrackerCategory) throws {
        let categoryCoreData = try trackerCategoryStore.categoryCoreData(with: category.id)
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.trackerId = tracker.id.uuidString
        trackerCoreData.createdAt = Date()
        trackerCoreData.label = tracker.title
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.colorHEX = ColorMarshalling.serialize(color: tracker.color)
        trackerCoreData.schedule = WeekDay.code(tracker.schedule)
        trackerCoreData.category = categoryCoreData
        trackerCoreData.isPinned = tracker.isPinned
        try context.save()
    }
    
    func updateTracker(_ tracker: Tracker, with data: Tracker.Data) throws {
        guard
            let emoji = data.emoji,
            let color = data.color,
            let category = data.category
        else { return }
        
        let trackerCoreData = try getTrackerCoreData(by: tracker.id)
        let categoryCoreData = try trackerCategoryStore.categoryCoreData(with: category.id)
        trackerCoreData?.label = data.label
        trackerCoreData?.emoji = emoji
        trackerCoreData?.colorHEX = ColorMarshalling.serialize(color: color)
        trackerCoreData?.schedule = WeekDay.code(data.schedule)
        trackerCoreData?.category = categoryCoreData
        try context.save()
    }
    
    
    func deleteTracker(_ tracker: Tracker) throws {
        guard let trackerToDelete = try getTrackerCoreData(by: tracker.id) else { throw StoreError.deleteError }
        context.delete(trackerToDelete)
        try context.save()
    }
    
    func togglePin(for tracker: Tracker) throws {
        guard let trackerToToggle = try getTrackerCoreData(by: tracker.id) else { throw StoreError.pinError }
        trackerToToggle.isPinned.toggle()
        try context.save()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}

// MARK: - Extension for an Array
extension Array {
     subscript(safe index: Index) -> Element? {
         indices ~= index ? self[index] : nil
     }
 }
