//
//  TrackerCoreManager+Pin.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 22.04.2024.
//

import CoreData

extension TrackerCoreManager {

    func pinTracker(indexPath: IndexPath) {
        guard let tracker = fetchedResultsController?.object(at: indexPath) else {
            print("Smth is going wrong"); return }
        tracker.isPinned = true
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

    func getAllUnPinnedTrackers() -> [TrackerCoreData]? {
        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerCoreData.isPinned),
                                    NSNumber(value: false))
        request.predicate = predicate

        do {
            return try context.fetch(request)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func getPinnedTrackerWithIndexPath(indexPath: IndexPath) -> TrackerCoreData? {
        guard let tracker = fetchedResultsController?.object(at: indexPath) else {
            print("Smth is going wrong")
            return nil
        }
        print("indexPath = \(indexPath) - getPinnedTrackerWithIndexPath \(tracker)")

        if tracker.isPinned == true {
            //            print("indexPath tracker.isPinned \(tracker.isPinned)")
            return tracker
        } else {
            //            print("indexPath tracker.isPinned \(tracker.isPinned)")
            return nil
        }
    }
}
