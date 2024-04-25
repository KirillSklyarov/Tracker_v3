//
//  TrackerCDManager+Statistics.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 21.04.2024.
//

import CoreData

// MARK: - Statistics
extension TrackerCoreManager {

    func isStickyCategoryExist() -> Bool {
        let request = TrackerCategoryCoreData.fetchRequest()

        do {
            let result = try context.fetch(request)
            let answer = !result.filter { $0.header == "Закрепленные" }.isEmpty
            return answer
        } catch {
            print("\(error.localizedDescription) 🟥")
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
        } catch {
            print("\(error.localizedDescription) 🟥")
        }
    }

    func countOfAllCompletedTrackers() -> Int {
        let request = TrackerRecordCoreData.fetchRequest()
        do {
            return try context.count(for: request)
        } catch {
            print("\(error.localizedDescription) 🟥")
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
        } catch {
            print("\(error.localizedDescription) 🟥")
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
        } catch {
            print("\(error.localizedDescription) 🟥")
            return ["Ooops"]
        }
    }

    func getAllTrackersForTheWeekDay(weekDay: String) -> [String: Int] {
        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K CONTAINS %@",
                                    #keyPath(TrackerCoreData.schedule), weekDay)
        request.predicate = predicate

        var result = [String: Int]()

        do {
            let data = try context.count(for: request)
            result[weekDay] = data
            return result
        } catch {
            print("\(error.localizedDescription) 🟥")
            return [:]
        }
    }

    func getAllTrackersForTheDay(weekDay: String) -> [String: Int] {
        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K CONTAINS %@",
                                    #keyPath(TrackerCoreData.schedule), weekDay)
        request.predicate = predicate

        var result = [String: Int]()

        do {
            let data = try context.count(for: request)
            result[weekDay] = data
            return result
        } catch {
            print("\(error.localizedDescription) 🟥")
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

        setupTrackerFRC(request: request)
    }

    func getTrackersExceptWithID(trackerNotToShow trackerId: [String], weekDay: String) {
        let request = TrackerCoreData.fetchRequest()
        let predicate1 = NSPredicate(format: "schedule CONTAINS %@", weekDay)
        let predicate2 = NSPredicate(format: "schedule CONTAINS %@", SGen.everyday)
        let predicate3 = NSPredicate(format: "NOT (%K IN %@)",
                                     #keyPath(TrackerCoreData.id), trackerId)
        let datePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate1, predicate2])
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, predicate3])
        request.predicate = compoundPredicate

        let sort = NSSortDescriptor(key: "category.header", ascending: true)
        request.sortDescriptors = [sort]

        filterButtonForEmptyScreenIsEnable = true

        setupTrackerFRC(request: request)
    }

    func getEmptyBaseForEmptyScreen() {
        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerCoreData.id.uuidString), "impossible trackerId")
        let sort = NSSortDescriptor(key: "category.header", ascending: true)
        request.predicate = predicate
        request.sortDescriptors = [sort]

        filterButtonForEmptyScreenIsEnable = true

        setupTrackerFRC(request: request)
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
        } catch {
            print("\(error.localizedDescription) 🟥")
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
        } catch {
            print("\(error.localizedDescription) 🟥")
            return [:]
        }
    }

    // Результат будет в таком формате:
    // ["51B64460-3E67-498F-A0FA-C8682B39341D": "Пн, Вт, Ср, Чт, Пт, Сб, Вс",
    // "FF035EEE-0F21-4C1A-8A52-58398F32259C": "Пн, Вт, Ср, Чт, Пт, Сб, Вс"]
    func getAllTrackers() -> [String: String] {
        let request = TrackerCoreData.fetchRequest()

        var trackers = [String: String]()
        do {
            let data = try context.fetch(request)

            for tracker in data {
                guard let trackerID = tracker.id else { return [:] }
                trackers[trackerID.uuidString] = tracker.schedule
            }
            print("AllTrackers \(trackers)")
            return trackers
        } catch {
            print("\(error.localizedDescription) 🟥")
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
        } catch {
            print("\(error.localizedDescription) 🟥")
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
        } catch {
            print("\(error.localizedDescription) 🟥")
            return [:]
        }
    }
}
