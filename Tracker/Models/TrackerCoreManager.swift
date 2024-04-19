//
//  TrackerCoreManager.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 26.03.2024.
//

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
    
    var lastChosenFilter: String?
    
    var filterButtonForEmptyScreenIsEnable = false
    
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
    
    func updateFetchedResultsControllerWithRequest(request: NSFetchRequest<TrackerCoreData>) {
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: "category.header",
            cacheName: nil)
        
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch  {
            print(error.localizedDescription)
        }
    }
        
    func getAllTrackersForWeekday(weekDay: String) {
        let request = TrackerCoreData.fetchRequest()
        let predicate1 = NSPredicate(format: "schedule CONTAINS %@", weekDay)
        let predicate2 = NSPredicate(format: "schedule CONTAINS %@", "Everyday".localized())
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate1, predicate2])
        let sort = NSSortDescriptor(key: "category.header", ascending: true)
        request.sortDescriptors = [sort]
        request.predicate = compoundPredicate
        
        updateFetchedResultsControllerWithRequest(request: request)
    }
    
    // MARK: - CRUD
    var collectionSections: [NSFetchedResultsSectionInfo]?
    
    func fetchData() -> [TrackerCategory] {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        do {
            let allTrackers = try context.fetch(fetchRequest)
            let result = transformCoreDataToModel(TrackerCategoryCoreData: allTrackers)
            print("fetchData: \n------------------------------")

            for trackerCategory in result {
                
                print("trackerCategory.header \(trackerCategory.header)")
                print("trackerCategory.trackers \(trackerCategory.trackers)")
                print("------------------------------")
            }
//            print("fetchData: \(result)")
            return result
        } catch  {
            print(error.localizedDescription)
            return []
        }
    }
    
    func printAllTrackersInCoreData() {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        do {
            let allTrackers = try context.fetch(fetchRequest)
            let result = transformCoreDataToModel(TrackerCategoryCoreData: allTrackers)
            print("printAllTrackersInCoreData: \(result)")
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    
    func transformCoreDataToModel(TrackerCategoryCoreData: [TrackerCategoryCoreData]) -> [TrackerCategory] {
        let trackersCategory = TrackerCategoryCoreData.compactMap({
            TrackerCategory(coreDataObject: $0)
        })
        return trackersCategory
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
            guard let category = result.first,
                  let tracker = newTracker.trackers.first else {
                print("May be here?"); return }
                
                let newTrackerToAdd = TrackerCoreData(context: context)
                newTrackerToAdd.id = tracker.id
                newTrackerToAdd.name = tracker.name
                newTrackerToAdd.colorHex = tracker.color
                newTrackerToAdd.emoji = tracker.emoji
                newTrackerToAdd.schedule = tracker.schedule
            
                category.addToTrackers(newTrackerToAdd)
                save()
                print("New Tracker created and Added to category \(header) ✅")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getCategoryNamesFromStorage() -> [String] {
        let request = TrackerCategoryCoreData.fetchRequest()
        let predicate = NSPredicate(format: "NOT (%K == %@)",
                                    #keyPath(TrackerCategoryCoreData.header), "Закрепленные")
        request.predicate = predicate
        
        let result = try? context.fetch(request)
        
        guard let result = result else { return ["Ошибка"]}
        let headers = result.map { $0.header ?? "Ooops" }
        
        return headers
    }
    
    func printAllCategoryNamesFromCD() {
        let request = TrackerCategoryCoreData.fetchRequest()
        let result = try? context.fetch(request)
        
        guard let result else { return }
        let headers = result.compactMap { $0.header }
        
        print("printAllCategoryNamesFromCD: \(headers)")
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
        
//        guard let sections = correctSectionsWithStickySectionFirst() else { print("Some shit"); return 0}
//        return sections[section].numberOfObjects
    }
    
//    func getObjectWithStickyCategory(indexPath: IndexPath) -> Any {
//        guard let sections = correctSectionsWithStickySectionFirst() else { print("Hmmm"); return 0}
////        print("sections: \(sections[indexPath.section].name)")
//        let object = sections[indexPath.section].objects![indexPath.item]
//        return object
//    }
    
//    func correctSectionsWithStickySectionFirst() ->  [any NSFetchedResultsSectionInfo]? {
//        guard var sections = fetchedResultsController?.sections else { print("We have some problems here"); return nil}
//        let firstIndex = sections.firstIndex { $0.name == "Закрепленные" }!
//        let firstSection = sections.remove(at: firstIndex)
//        sections.insert(firstSection, at: 0)
//        return sections
//    }
    
    
    func numberOfRowsInStickySection() -> Int {
        guard let sections = fetchedResultsController?.sections else { print("Hmmm"); return 0}
        
        for section in sections {
//            print(section.objects as Any)
            if section.name == "Закрепленные" {
                return section.numberOfObjects
            }
        }
        print("We can't find any elements in sticky Cat")
        return 0
    }
    
    
    func object(at indexPath: IndexPath) -> TrackerCoreData? {
        fetchedResultsController?.object(at: indexPath)
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
        print("TrackerCategory deleted successfully ✅")
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

// MARK: - Filter
extension TrackerCoreManager {
    func sendLastChosenFilterToStore(filterName: String) {
        self.lastChosenFilter = filterName
    }
    
    func getLastChosenFilterFromStore() -> String {
        if let lastChosenFilter =  self.lastChosenFilter{
            return lastChosenFilter
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
    
    func deleteAllRecords() {
        let request: NSFetchRequest<NSFetchRequestResult> = TrackerRecordCoreData.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            print("All TrackerRecords deleted successfully ✅")
            save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func printAllTrackerRecords() {
        let request = TrackerRecordCoreData.fetchRequest()
        
        do {
            let result = try context.fetch(request)
            print("AllTrackerRecord: \(result)")
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
    
    func deleteTracker(at indexPath: IndexPath) {
        
        deleteAllTrackerRecordsForTracker(at: indexPath)
        
        guard let tracker = fetchedResultsController?.object(at: indexPath) else { print("Smth is going wrong"); return }
        context.delete(tracker)
        print("Tracker deleted ✅")
        save()
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
    
    func deleteTrackerFromCategory(categoryName: String, trackerIDToDelete: UUID) {
        let request = TrackerCategoryCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerCategoryCoreData.header),
                                    categoryName)
        request.predicate = predicate
        
        do {
            guard let result = try context.fetch(request).first,
                  let trackers = result.trackers as? Set<TrackerCoreData> else { return }
            for tracker in trackers {
                if tracker.id?.uuidString == trackerIDToDelete.uuidString {
                    context.delete(tracker)
                    print("Tracker removed from previous category successfully ✅")
                    save()
                }
            }
        } catch  {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Statistics
extension TrackerCoreManager {
    
    func isStickyCategoryExist() -> Bool {
        let request = TrackerCategoryCoreData.fetchRequest()
        
        do {
            let result = try context.fetch(request)
            let answer = !result.filter { $0.header == "Закрепленные" }.isEmpty
            return answer
        } catch  {
            print(error.localizedDescription)
            return false
        }
    }
    
    func fixingTracker(tracker: TrackerCoreData) {
        if isStickyCategoryExist() {
            addTrackerToExistingStickyCategory(tracker: tracker)
        } else {
            createStickyCategoryAndAddTracker(tracker: tracker)
        }
    }
    
    func createStickyCategoryAndAddTracker(tracker: TrackerCoreData) {
        let stickyCategory = TrackerCategoryCoreData(context: context)
        stickyCategory.header = "Закрепленные"
        
        let newTrackerToAdd = TrackerCoreData(context: context)
        newTrackerToAdd.id = tracker.id
        newTrackerToAdd.name = tracker.name
        newTrackerToAdd.colorHex = tracker.colorHex
        newTrackerToAdd.emoji = tracker.emoji
        newTrackerToAdd.schedule = tracker.schedule
        
        stickyCategory.addToTrackers(newTrackerToAdd)
        save()
        print("Sticky Category created an Tracker is stick successfully ✅")
    }
    
    func addTrackerToExistingStickyCategory(tracker: TrackerCoreData) {
        let request = TrackerCategoryCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerCategoryCoreData.header),
                                    "Закрепленные")
        request.predicate = predicate
        
        do {
            let result = try context.fetch(request)
            guard let stickyCategory = result.first else { print("Jopa"); return }
            
            let newTrackerToAdd = TrackerCoreData(context: context)
            newTrackerToAdd.id = tracker.id
            newTrackerToAdd.name = tracker.name
            newTrackerToAdd.colorHex = tracker.colorHex
            newTrackerToAdd.emoji = tracker.emoji
            newTrackerToAdd.schedule = tracker.schedule
            
            stickyCategory.addToTrackers(newTrackerToAdd)
            save()
            print("Tracker is Fixed successfully ✅")
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    
    func countOfAllCompletedTrackers() -> Int {
        let request = TrackerRecordCoreData.fetchRequest()
        do {
            return try context.count(for: request)
        } catch  {
            print(error.localizedDescription)
            return 0
        }
    }
    
    func getAllTrackerRecordDates() -> [String?] {
        let request = TrackerRecordCoreData.fetchRequest()
        
        var result = [String?]()
        do {
            let data = try context.fetch(request)
            for tracker in data {
                result.append(tracker.date)
            }
            return result
        } catch  {
            print(error.localizedDescription)
            return ["Ooops"]
        }
    }
    
    func getAllTrackerRecordForDate(date: String) -> [String?] {
        let request = TrackerRecordCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerRecordCoreData.date),
                                    date)
        request.predicate = predicate
        request.propertiesToFetch = ["id"]
        
        var result = [String?]()
        do {
            let data = try context.fetch(request)
            for tracker in data {
                result.append(tracker.id?.uuidString)
            }
            return result
        } catch  {
            print(error.localizedDescription)
            return ["Ooops"]
        }
    }
    
   
    func getAllTrackersForTheWeekDay(weekDay: String) -> [String:Int] {
        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K CONTAINS %@",
                                    #keyPath(TrackerCoreData.schedule), weekDay)
        request.predicate = predicate
        
        var result = [String:Int]()
        
        do {
            let data = try context.count(for: request)
            result[weekDay] = data
            return result
        } catch  {
            print(error.localizedDescription)
            return [:]
        }
    }
    
    
    func getAllTrackersForTheDay(weekDay: String) -> [String:Int] {
        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K CONTAINS %@",
                                    #keyPath(TrackerCoreData.schedule), weekDay)
        request.predicate = predicate
        
        var result = [String:Int]()
        
        do {
            let data = try context.count(for: request)
            result[weekDay] = data
            return result
        } catch  {
            print(error.localizedDescription)
            return [:]
        }
    }
    
    func getTrackerWithID(trackerId: [String]) {
        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K IN %@",
                                    #keyPath(TrackerCoreData.id), trackerId)
        let sort = NSSortDescriptor(key: "category.header", ascending: true)
        request.predicate = predicate
        request.sortDescriptors = [sort]
        
        updateFetchedResultsControllerWithRequest(request: request)
    }
    
    func getTrackersExceptWithID(trackerNotToShow trackerId: [String], weekDay: String) {
        let request = TrackerCoreData.fetchRequest()
        let predicate1 = NSPredicate(format: "schedule CONTAINS %@", weekDay)
        let predicate2 = NSPredicate(format: "schedule CONTAINS %@", "Everyday".localized())
        let predicate3 = NSPredicate(format: "NOT (%K IN %@)",
                                    #keyPath(TrackerCoreData.id), trackerId)
        let datePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate1, predicate2])
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, predicate3])
        request.predicate = compoundPredicate
        
        let sort = NSSortDescriptor(key: "category.header", ascending: true)
        request.sortDescriptors = [sort]
        
        filterButtonForEmptyScreenIsEnable = true
        
        updateFetchedResultsControllerWithRequest(request: request)
    }
    
    func getEmptyBaseForEmptyScreen() {
        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerCoreData.id.uuidString), "impossible trackerId")
        let sort = NSSortDescriptor(key: "category.header", ascending: true)
        request.predicate = predicate
        request.sortDescriptors = [sort]
        
        filterButtonForEmptyScreenIsEnable = true
        
        updateFetchedResultsControllerWithRequest(request: request)
    }
    
    func getAllTrackerRecordsDaysAndCounts() -> [String: Int] {
        let request = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        var countsByDate: [String: Int] = [:]

        do {
            let data = try context.fetch(request)
            
            for tracker in data {
                countsByDate[tracker.date!] = (countsByDate[tracker.date!] ?? 0) + 1
            }
            let sortedArray = countsByDate.sorted(by: {$0.key < $1.key})
            return Dictionary(uniqueKeysWithValues: sortedArray)
        } catch  {
            print(error.localizedDescription)
            return [:]
        }
    }
    
    func getTrackerRecordsCountsForDate(date: String) -> [String: Int] {
        let request = TrackerRecordCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K CONTAINS %@",
                                    #keyPath(TrackerRecordCoreData.date), date)
        request.predicate = predicate
        
        var trackerRecordsForDate: [String: Int] = [:]

        do {
            let data = try context.fetch(request)
            
            for tracker in data {
                trackerRecordsForDate[tracker.date!] = (trackerRecordsForDate[tracker.date!] ?? 0) + 1
            }
            let sortedArray = trackerRecordsForDate.sorted(by: {$0.key < $1.key})
            return Dictionary(uniqueKeysWithValues: sortedArray)
        } catch  {
            print(error.localizedDescription)
            return [:]
        }
    }
    
    // Результат будет в таком формате: ["51B64460-3E67-498F-A0FA-C8682B39341D": "Пн, Вт, Ср, Чт, Пт, Сб, Вс", "FF035EEE-0F21-4C1A-8A52-58398F32259C": "Пн, Вт, Ср, Чт, Пт, Сб, Вс"]
    func getAllTrackers() -> [String:String] {
        let request = TrackerCoreData.fetchRequest()
        
        var trackers = [String:String]()
        do {
            let data = try context.fetch(request)
            
            for tracker in data {
                guard let trackerID = tracker.id else { return [:] }
                trackers[trackerID.uuidString] = tracker.schedule
            }
            print("AllTrackers \(trackers)")
            return trackers
        } catch  {
            print(error.localizedDescription)
            return [:]
        }
    }
    
    func getAllTrackerRecordsIDAndCounts() -> [String: [String]] {
        let request = TrackerRecordCoreData.fetchRequest()
        request.propertiesToFetch = ["id", "date"]
        
        var countsByID: [String: [String]] = [:]
        
        do {
            let data = try context.fetch(request)
            
            for tracker in data {
                if countsByID[tracker.id!.uuidString] == nil {
                    countsByID[tracker.id!.uuidString] = [tracker.date!]
                } else {
                    countsByID[tracker.id!.uuidString]?.append(tracker.date!)
                }
            }
            return countsByID
        } catch  {
            print(error.localizedDescription)
            return [:]
        }
    }
    
    func getTrackerRecordsForTheTracker(trackerID: String) -> [String: [String]]? {
        let request = TrackerRecordCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerRecordCoreData.id),
                                    trackerID)
        request.predicate = predicate
        request.propertiesToFetch = ["id", "date"]
        
        
        var countsByID: [String: [String]] = [:]
        
        do {
            let data = try context.fetch(request)
            
            for tracker in data {
                if countsByID[tracker.id!.uuidString] == nil {
                    countsByID[tracker.id!.uuidString] = [tracker.date!]
                } else {
                    countsByID[tracker.id!.uuidString]?.append(tracker.date!)
                }
            }
            return countsByID
        } catch  {
            print(error.localizedDescription)
            return [:]
        }
    }
    
    
    
    
    
}
