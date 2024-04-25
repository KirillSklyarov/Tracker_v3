//
//  TrackerCoreManager+Pin.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 22.04.2024.
//

import CoreData

extension TrackerCoreManager {

    func setupPinnedFRC() {
        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerCoreData.isPinned), NSNumber(value: true))
        let sort = NSSortDescriptor(key: "category.header", ascending: true)
        request.sortDescriptors = [sort]
        request.predicate = predicate

        pinnedTrackersFRC = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: "category.header",
            cacheName: nil)

        pinnedTrackersFRC?.delegate = self

        do {
            try pinnedTrackersFRC?.performFetch()
        } catch {
            print("\(error.localizedDescription) 🟥")
        }
    }

    func pinTracker(indexPath: IndexPath) {
        guard let tracker = trackersFRC?.object(
            at: indexPath) else {
            print("Smth is going wrong")
            return }
        //        print("indexPath \(indexPath)")
        //        print("tracker.name \(tracker.name)")
        tracker.isPinned = true
        print("Tracker is Pinned ✅")
        save()
    }

    func unpinTracker(indexPath: IndexPath) {
        guard let tracker = pinnedTrackersFRC?.object(at: indexPath) else {
            print("Smth is going wrong"); return }
        //        print("indexPath \(indexPath)")
        //        print("tracker.name \(tracker.name)")
        tracker.isPinned = false
        print("Tracker is Pinned ✅")
        save()
    }

    func getAllPinnedTrackers() -> [TrackerCoreData]? {
        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerCoreData.isPinned), NSNumber(value: true))
        request.predicate = predicate

        do {
            return try context.fetch(request)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func getAllUnPinnedTrackers() -> [TrackerCategory] {
        let request = TrackerCategoryCoreData.fetchRequest()
        let predicate = NSPredicate(format: "ANY %K == %@",
                                    #keyPath(TrackerCategoryCoreData.trackers.isPinned), NSNumber(value: false))
        request.predicate = predicate

        let sort = NSSortDescriptor(key: "header", ascending: true)
        request.sortDescriptors = [sort]

        do {
            let allTrackers = try context.fetch(request)
            let result = transformCoreDataToModel(trackerCategoryCoreData: allTrackers)

            //            print("result \(result)")

            return result
        } catch {
            print(error.localizedDescription)
            return []
        }
    }

    func getPinnedTrackerWithIndexPath(indexPath: IndexPath) -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerCoreData.isPinned),
                                    NSNumber(value: true))
        request.predicate = predicate

        do {
            let result = try context.fetch(request)
            let tracker = result[indexPath.row]
            return tracker
            //            print("result \(result)")
            //            print("tracker \(tracker.name), \(tracker.id)")
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func deleteTrackerWithID(trackerID: String) {

        deleteAllTrackerRecordsForTracker(trackerID: trackerID)

        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerCoreData.id),
                                    trackerID)
        request.predicate = predicate

        do {
            let result = try context.fetch(request)
            guard let trackerToDelete = result.first else {
                print("We have issues here")
                return
            }
            context.delete(trackerToDelete)
            print("Tracker deleted ✅")
            save()
        } catch {
            print("\(error.localizedDescription) 🟥")
        }
    }
}
