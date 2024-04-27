//
//  TrackerCDManager+TrackerRecord.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 21.04.2024.
//

import CoreData

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
            print("\(error.localizedDescription) 🟥")
        }
    }

    func printAllTrackerRecords() {
        let request = TrackerRecordCoreData.fetchRequest()

        do {
            let result = try context.fetch(request)
            for element in result {
                print("element.date \(String(describing: element.date)), element.id \(String(describing: element.id))")
            }
        } catch {
            print("\(error.localizedDescription) 🟥")
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
        } catch {
            print("\(error.localizedDescription) 🟥")
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
        } catch {
            print("\(error.localizedDescription) 🟥")
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
        } catch {
            print("\(error.localizedDescription) 🟥")
            return 0
        }
    }

    func deleteTracker(at indexPath: IndexPath) {

        deleteAllTrackerRecordsForTracker(at: indexPath)

        guard let tracker = trackersFRC?.object(at: indexPath) else {
            print("Smth is going wrong"); return }
        context.delete(tracker)
        print("Tracker deleted ✅")
        save()
    }

    func deleteAllTrackerRecordsForTracker(at indexPath: IndexPath) {
        guard let tracker = trackersFRC?.object(at: indexPath),
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
        } catch {
            print("\(error.localizedDescription) 🟥")
        }
    }

    func deleteAllTrackerRecordsForTracker(trackerID: String) {
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
        } catch {
            print("\(error.localizedDescription) 🟥")
        }
    }

    func deleteTrackerFromCategory(categoryName: String, trackerIDToDelete: UUID) {
        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerCoreData.id),
                                    trackerIDToDelete.uuidString)
        request.predicate = predicate

        do {
            let result = try context.fetch(request)
            for tracker in result where tracker.category?.header == categoryName {
                context.delete(tracker)
                print("Tracker removed from previous category (\(categoryName)) successfully ✅")
                save()
            }
        } catch {
            print("\(error.localizedDescription) 🟥")
        }
    }
}
