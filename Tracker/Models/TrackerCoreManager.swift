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
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError(error.localizedDescription)
            } else {
                print("DB loaded successfully ✅")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
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
        } catch {
            print(error.localizedDescription)
        }
    }

    func getAllTrackersForWeekday(weekDay: String) {
        let request = TrackerCoreData.fetchRequest()
        let predicate1 = NSPredicate(format: "schedule CONTAINS %@", weekDay)
        let predicate2 = NSPredicate(format: "schedule CONTAINS %@", SGen.everyday)
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
            let result = transformCoreDataToModel(trackerCategoryCoreData: allTrackers)
            print("fetchData: \n------------------------------")

            for trackerCategory in result {
                print("trackerCategory.header \(trackerCategory.header)")
                print("trackerCategory.trackers \(trackerCategory.trackers)")
                print("------------------------------")
            }
            //            print("fetchData: \(result)")
            return result
        } catch {
            print(error.localizedDescription)
            return []
        }
    }

    func printAllTrackersInCoreData() {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        do {
            let allTrackers = try context.fetch(fetchRequest)
            let result = transformCoreDataToModel(trackerCategoryCoreData: allTrackers)
            print("printAllTrackersInCoreData: \(result)")
        } catch {
            print(error.localizedDescription)
        }
    }

    func transformCoreDataToModel(trackerCategoryCoreData: [TrackerCategoryCoreData]) -> [TrackerCategory] {
        let trackersCategory = trackerCategoryCoreData.compactMap({
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
        } catch {
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
    //        guard var sections = fetchedResultsController?.sections else { print("We have problems here"); return nil}
    //        let firstIndex = sections.firstIndex { $0.name == "Закрепленные" }!
    //        let firstSection = sections.remove(at: firstIndex)
    //        sections.insert(firstSection, at: 0)
    //        return sections
    //    }

    func numberOfRowsInStickySection() -> Int {
        guard let sections = fetchedResultsController?.sections else { print("Hmmm"); return 0}

        for section in sections where section.name == "Закрепленные" {
            //            print(section.objects as Any)
            //            if section.name == "Закрепленные" {
            return section.numberOfObjects
            //            }
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
        } catch {
            print(error.localizedDescription)
        }
    }

    func isCategoryEmpty(header: String) -> Bool? {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "category.header == %@", header)
        do {
            let count = try context.count(for: request)
            return count <= 1 ? true : false
        } catch {
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
        if let lastChosenCategory =  self.lastChosenCategory {
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
        if let lastChosenFilter =  self.lastChosenFilter {
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

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {

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
