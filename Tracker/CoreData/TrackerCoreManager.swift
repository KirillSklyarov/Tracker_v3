//
//  TrackerCoreManager.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 26.03.2024.
//

import Foundation
import CoreData
import UIKit

struct TrackersStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol DataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackersStoreUpdate)
}

final class TrackerCoreManager: NSObject {
    
    static let shared = TrackerCoreManager()
    
    private override init() {
    }
    
    weak var delegate: DataProviderDelegate?
    
    // MARK: - Container, context
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerCoreData")
        container.loadPersistentStores { (description, error) in
            if let error = error as NSError? {
                fatalError(error.localizedDescription)
            } else {
                print("DB url: ", description.url ?? "Oooops")
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
        let predicate = NSPredicate(format: "schedule CONTAINS %@", weekDay)
        let sort = NSSortDescriptor(key: "category.header", ascending: true)
        request.sortDescriptors = [sort]
        request.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: context,
                                                              sectionNameKeyPath: "category.header",
                                                              cacheName: nil)
        
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Fetch failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - CRUD
    func fetchData() -> [TrackerCategory] {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        do {
            let allTrackers = try context.fetch(fetchRequest)
            let result = transformCoreDataToModel(TrackerСategoryCoreData: allTrackers)
            return result
        } catch  {
            print(error.localizedDescription)
            return []
        }
    }
    
    
    func renameCategory() {
        
    }
    
    func transformCoreDataToModel(TrackerСategoryCoreData: [TrackerCategoryCoreData]) -> [TrackerCategory] {
        let trackersCategory = TrackerСategoryCoreData.compactMap({
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
        print("We're here - createNewCategory")
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.header = newCategoryName
        save()
        print("New Category created ✅")
    }
    
    func createNewTracker(newTracker: TrackerCategory) {
        print("We're here - createNewTracker")
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
        var arrayOfCategoryNames = [String]()
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        let allTrackers = try? context.fetch(fetchRequest)
        
        if let allTrackers = allTrackers {
            for i in allTrackers {
                arrayOfCategoryNames.append(i.header ?? "ЭЭ")
            }
        }
        let uniqueCategoryNames = Array(Set(arrayOfCategoryNames))
        
        return uniqueCategoryNames
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
}



//func fetchTrackers(currentWeekDay: WeekDay) {
//    fetchedResultsController.fetchRequest.predicate = NSPredicate(
//        format: "%K CONTAINS[cd] %@",
//        #keyPath(TrackerCoreData.weekDays), currentWeekDay.englishStringRepresentation)
//    try? fetchedResultsController.performFetch()
//}


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



