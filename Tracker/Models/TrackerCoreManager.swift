//
//  TrackerCoreManager.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 26.03.2024.
//

import UIKit
import CoreData

struct TrackersStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol DataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackersStoreUpdate)
}

final class TrackerCoreManager: NSObject {
    
    static let shared = TrackerCoreManager()
    
    weak var delegate: DataProviderDelegate?

    var lastChosenCategory: String?
    
    private override init() { }
    
    // MARK: - Container, context
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerCoreData")
        container.loadPersistentStores { (description, error) in
            if let error = error as NSError? {
                fatalError(error.localizedDescription)
            } else {
                print("DB loaded successfully ✅")
            }
        }
        return container
    } ()
    
    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    var insertedIndexes: IndexSet?
    var deletedIndexes: IndexSet?
    
    // MARK: - FetchResultsController
    var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    func setupFetchedResultsController(weekDay: String) {
        let request = TrackerCoreData.fetchRequest()
        let predicate1 = NSPredicate(format: "schedule CONTAINS %@", weekDay)
        let predicate2 = NSPredicate(format: "schedule CONTAINS %@", "Каждый день")
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate1, predicate2])
        let sort = NSSortDescriptor(key: "category.header", ascending: true)
        request.sortDescriptors = [sort]
        request.predicate = compoundPredicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: context,
                                                              sectionNameKeyPath: "category.header",
                                                              cacheName: nil)
        
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
//            if let results = fetchedResultsController?.fetchedObjects {
//                for element in results {
//                    print(element.name as Any)
//                    print(element.schedule as Any)
//                }
//            }
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - CRUD
    func printCoreData() {
        let request = TrackerCoreData.fetchRequest()
        let sort = NSSortDescriptor(key: "category.header", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            let result = try context.fetch(request)
//            for element in result {
//                print(element)
//                print(element.name as Any)
//                print(element.schedule as Any)
//                print(element.category?.header as Any)
//            }
        } catch  {
            print(error.localizedDescription)
        }
        
    }
    
    func fetchData() -> [TrackerCategory] {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        do {
            let allTrackers = try context.fetch(fetchRequest)
            let result = transformCoreDataToModel(TrackerCategoryCoreData: allTrackers)
            return result
        } catch  {
            print(error.localizedDescription)
            return []
        }
    }
    
    func transformCoreDataToModel(TrackerCategoryCoreData: [TrackerCategoryCoreData]) -> [TrackerCategory] {
        let trackersCategory = TrackerCategoryCoreData.compactMap({
            TrackerCategory(coreDataObject: $0)
        })
        return trackersCategory
    }
    
    func deleteOneItem(trackerCategoryCoreData: TrackerCategoryCoreData) {
        context.delete(trackerCategoryCoreData)
        save()
    }
    
    func deleteAllItems() {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        do {
            var allTrackers = try context.fetch(fetchRequest)
            allTrackers.removeAll()
            save()
            print("Data deleted ✅")
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func createNewCategory(newCategoryName: String) {
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.header = newCategoryName
        save()
        print("New Category created ✅")
    }
    
    func createNewTracker(newTracker: TrackerCategory) {
        let header = newTracker.header
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "header = %@", header)
        
        do {
            let result = try context.fetch(fetchRequest)
            if let foundCategory = result.first {
                guard let color = newTracker.trackers.first?.color else { return }
                let colorInString = color.hexStringFromUIColor()
                
                let newTrackerToAdd = TrackerCoreData(context: context)
                newTrackerToAdd.id = newTracker.trackers.first?.id
                newTrackerToAdd.name = newTracker.trackers.first?.name
                newTrackerToAdd.colorHex = colorInString
                newTrackerToAdd.emoji = newTracker.trackers.first?.emoji
                newTrackerToAdd.schedule = newTracker.trackers.first?.schedule
                
                foundCategory.addToTrackers(newTrackerToAdd)
                save()
                print("New Tracker created and Added TO EXISTING CAT ✅")
            }
        } catch  {
            let newTrackerCategory = TrackerCategoryCoreData(context: context)
            newTrackerCategory.header = newTracker.header
            
            guard let color = newTracker.trackers.first?.color else { return }
            let colorInString = color.hexStringFromUIColor()
            
            let newTrackerToAdd = TrackerCoreData(context: context)
            newTrackerToAdd.id = newTracker.trackers.first?.id
            newTrackerToAdd.name = newTracker.trackers.first?.name
            newTrackerToAdd.colorHex = colorInString
            newTrackerToAdd.emoji = newTracker.trackers.first?.emoji
            newTrackerToAdd.schedule = newTracker.trackers.first?.schedule
            
            newTrackerCategory.addToTrackers(newTrackerToAdd)
            save()
            print("New Tracker created and Added TO NEW CAT ✅")
        }
    }
    
    
    func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do  {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getCategoryNamesFromStorage() -> [String] {
        let request = TrackerCategoryCoreData.fetchRequest()
        let result = try? context.fetch(request)
        
        guard let result = result else { return ["Ошибка"]}
        let headers = result.map { $0.header ?? "Ooops" }
        
        return headers
    }
}

extension TrackerCoreManager: NSFetchedResultsControllerDelegate {
    
    var isCoreDataEmpty: Bool {
        fetchedResultsController?.sections?.isEmpty ?? true
    }
    
    var numberOfSections: Int {
        fetchedResultsController?.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerCoreData? {
        fetchedResultsController?.object(at: indexPath)
    }
    
    func deleteTracker(at indexPath: IndexPath) {
        guard let tracker = fetchedResultsController?.object(at: indexPath) else { print("Smth is going wrong"); return }
        context.delete(tracker)
        print("Tracker deleted ✅")
        save()
    }
    
    func printAllTrackersInCategory(header: String) {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "category.header == %@", header)
        do {
            let results = try context.fetch(request)
            for trackers in results {
                print("trackers: \(trackers)")
            }
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func isCategoryEmpty(header: String) -> Bool? {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "category.header == %@", header)
        do {
            let count = try context.count(for: request)
            return count <= 1 ? true : false
        } catch  {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func getTrackersForWeekDay(weekDay: String) {
        let request = fetchedResultsController?.fetchRequest
        let predicate = NSPredicate(format: "%K CONTAINS %@",
                                    #keyPath(TrackerCoreData.schedule), weekDay)
        let sort = NSSortDescriptor(key: "category.header", ascending: true)
        request?.sortDescriptors = [sort]
        request?.predicate = predicate
        do {
            try? fetchedResultsController?.performFetch()
            print("Tracker updated to weekday ✅")
        }
    }
    
    func renameCategory(header: String, newHeader: String) {
        let request = TrackerCategoryCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerCategoryCoreData.header), header)
        request.predicate = predicate
        
        let categoryHeader = try? context.fetch(request).first
        categoryHeader?.header = newHeader
        print("TrackerCategoryHeader renamed successfully ✅")
        save()
    }
    
    func deleteCategory(header: String) {
        
        guard !header.isEmpty else { print("Hmmmmm"); return }
        
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(TrackerCategoryCoreData.header), header)
        guard let categoryHeader = try? context.fetch(request).first else {
            print("We have some problems here"); return
        }
        
        guard let trackers = categoryHeader.trackers as? Set<TrackerCoreData> else { print("U-la-la"); return }
        
        for tracker in trackers {
            context.delete(tracker)
        }
        
        context.delete(categoryHeader)
        print("TrackerCategoryHeader deleted successfully ✅")
        save()
    }
    
    func sendLastChosenCategoryToStore(categoryName: String) {
        self.lastChosenCategory = categoryName
    }
    
    func getLastChosenCategoryFromStore() -> String {
        if let lastChosenCategory =  self.lastChosenCategory{
            return lastChosenCategory
        } else {
            return "Smth is going wrong"
        }
    }
}

extension TrackerCoreManager {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.didUpdate(TrackersStoreUpdate(
            insertedIndexes: insertedIndexes!,
            deletedIndexes: deletedIndexes!
        )
        )
        insertedIndexes = nil
        deletedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}

// MARK: - TrackerRecord
extension TrackerCoreManager {
    
    func printTrackerRecord() {
        let request = TrackerRecordCoreData.fetchRequest()
        
        do {
            let result = try context.fetch(request)
//            print(result)
        } catch  {
            print(error.localizedDescription)
        }
    }
        
    func addTrackerRecord(trackerToAdd: TrackerRecord) {
        let newTrackerRecord = TrackerRecordCoreData(context: context)
        newTrackerRecord.id = trackerToAdd.id
        newTrackerRecord.date = trackerToAdd.date
        save()
        print("New TrackerRecord created ✅")
    }
    
    func removeTrackerRecordForThisDay(trackerToRemove: TrackerRecord) {
        let request = TrackerRecordCoreData.fetchRequest()
        let predicate1 = NSPredicate(format: "%K == %@",
                                     #keyPath(TrackerRecordCoreData.id), trackerToRemove.id.uuidString )
        let predicate2 = NSPredicate(format: "%K == %@",
                                     #keyPath(TrackerRecordCoreData.date), trackerToRemove.date)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        request.predicate = compoundPredicate
        
        do {
            let result = try context.fetch(request)
            if let trackerToDelete = result.first {
                context.delete(trackerToDelete)
                print("Tracker Record deleted ✅")
                save()
            } else {
                print("We can't find the tracker")
            }
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func isTrackerExistInTrackerRecord(trackerToCheck: TrackerRecord) -> Bool {
        let request = TrackerRecordCoreData.fetchRequest()
        let predicate1 = NSPredicate(format: "%K == %@",
                                     #keyPath(TrackerRecordCoreData.id), 
                                     trackerToCheck.id.uuidString)
        let predicate2 = NSPredicate(format: "%K == %@",
                                     #keyPath(TrackerRecordCoreData.date), 
                                     trackerToCheck.date)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        request.predicate = compoundPredicate
        
        do {
            let result = try context.count(for: request)
            return result > 0
        } catch  {
            print(error.localizedDescription)
            return false
        }
    }
    
    func countOfTrackerInRecords(trackerIDToCount: String) -> Int {
        let request = TrackerRecordCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerRecordCoreData.id),
                                    trackerIDToCount)
        request.predicate = predicate
        
        do {
           return try context.count(for: request)
        } catch  {
            print(error.localizedDescription)
            return 0
        }
    }
    
    func deleteAllTrackerRecordsForTracker(at indexPath: IndexPath) {
        guard let tracker = fetchedResultsController?.object(at: indexPath),
              let trackerID = tracker.id?.uuidString else { print("Smth is going wrong"); return }
        let request = TrackerRecordCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerRecordCoreData.id), trackerID)
        request.predicate = predicate
        
        do {
            let result = try context.fetch(request)
            for records in result {
                context.delete(records)
                save()
            }
            print("TrackerRecords for this tracker deleted ✅")
        } catch  {
            print(error.localizedDescription)
        }
    }
}
