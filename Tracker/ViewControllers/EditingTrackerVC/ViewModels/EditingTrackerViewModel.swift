//
//  EditingViewModel.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 11.04.2024.
//

import Foundation

final class EditingTrackerViewModel: EditingTrackerViewModelProtocol {

    var tableViewRows = [SGen.category, SGen.schedule]

    var arrayOfEmoji = MainHelper.arrayOfEmoji

    var arrayOfColors = MainHelper.arrayOfColors

    let coreDataManager = TrackerCoreManager.shared

    var trackerName: String? {
        didSet {
            updateSaveButton?()
        }
    }

    var emoji: String? {
        didSet {
            updateSaveButton?()
        }
    }

    var color: String? {
        didSet {
            updateSaveButton?()
        }
    }

    var category: String? {
        didSet {
            updateSaveButton?()
        }
    }

    var countOfCompletedDays: String? {
        didSet {
            updateSaveButton?()
        }
    }

    var schedule: String? {
        didSet {
            updateSaveButton?()
        }
    }

    var initialTrackerCategory: String?

    var indexPath: IndexPath?

    var trackerId: UUID?

    var updateSaveButton: ( () -> Void )?

    var emojiIndexPath: IndexPath? {
        guard let emoji,
              let emojiIndex = arrayOfEmoji.firstIndex(of: emoji) else { print("Oops"); return nil}
        return IndexPath(row: emojiIndex, section: 0)
    }

    var colorIndexPath: IndexPath? {
        guard let color,
              let colorIndex = arrayOfColors.firstIndex(of: color) else { print("Oops"); return nil}
        return IndexPath(row: colorIndex, section: 0)
    }

    var isPinned = false

    func getBackToMainScreen() {
        let cancelCreatingTrackerNotification = Notification.Name("cancelCreatingTracker")
        NotificationCenter.default.post(name: cancelCreatingTrackerNotification, object: nil)
    }

    func createNewTracker() {
        guard let name = trackerName,
              let category = category,
              let color = color,
              let emoji = emoji,
              let schedule = schedule else {
            print("Smth's going wrong here"); return
        }

        let newTask = TrackerCategory(
            header: category,
            trackers: [Tracker(id: UUID(),
                               name: name,
                               color: color,
                               emoji: emoji,
                               schedule: schedule,
                               isPinned: isPinned)
            ])
        coreDataManager.createNewTracker(newTracker: newTask)
        getBackToMainScreen()
    }

    func isAllFieldsFilled() -> Bool {
        let allFieldsFilled =
        trackerName != nil &&
        trackerName != "" &&
        category != nil &&
        schedule != nil &&
        emoji != nil &&
        color != nil
        return allFieldsFilled
    }

    func getTrackerDataForEditing(tracker: TrackerCoreData) {
        guard let trackerID = tracker.id else { return }
        let countOfDays = MainHelper.countOfDaysForTheTrackerInString(trackerId: trackerID.uuidString)

        trackerId = tracker.id
        trackerName = tracker.name
        category = tracker.category?.header
        schedule = tracker.schedule
        emoji = tracker.emoji
        color = tracker.colorHex
        countOfCompletedDays = countOfDays

        initialTrackerCategory = tracker.category?.header
        isPinned = tracker.isPinned
    }

    func updateTracker() {
        if isPinned {
            //            print("Tracker is Pinned")
            updatePinnedTracker()
        } else {
            //            print("Tracker is NOT Pinned")
            updateUnpinnedTracker()
        }
    }

    func updatePinnedTracker() {
        guard let indexPath,
              let tracker = coreDataManager.pinnedTrackersFRC?.object(at: indexPath) else { print("Ooops"); return }

        if isCategoryChanged() {
            changeTrackerCategory(tracker: tracker)
        } else {
            updateTracker(tracker: tracker)
        }
    }

    func updateTracker(tracker: TrackerCoreData) {
        tracker.name = trackerName
        tracker.schedule = schedule
        tracker.emoji = emoji
        tracker.colorHex = color

        coreDataManager.save()

        print("Tracker updated successfully ✅")
    }

    func updateUnpinnedTracker() {

        guard let indexPath,
              let tracker = coreDataManager.trackersFRC?.object(at: indexPath) else {
            print("We cant find tracker"); return }

        if isCategoryChanged() {
            changeTrackerCategory(tracker: tracker)
        } else {
            updateTracker(tracker: tracker)
        }
    }

    func isCategoryChanged() -> Bool {
        return category != initialTrackerCategory
    }

    func changeTrackerCategory(tracker: TrackerCoreData) {
        guard let category,
              let initialTrackerCategory,
              let id = tracker.id,
              let name = tracker.name,
              let colorHex = tracker.colorHex,
              let emoji = tracker.emoji,
              let schedule = tracker.schedule else {
            print("Hmmmm, bad thing"); return
        }

        let trackerWithAnotherCategory = TrackerCategory(
            header: category,
            trackers: [Tracker(
                id: id,
                name: name,
                color: colorHex,
                emoji: emoji,
                schedule: schedule,
                isPinned: tracker.isPinned
            )
            ])

        print(trackerWithAnotherCategory)

        coreDataManager.createNewTracker(newTracker: trackerWithAnotherCategory)

        coreDataManager.deleteTrackerFromCategory(categoryName: initialTrackerCategory, trackerIDToDelete: id)

        //        let allDataAfter = coreDataManager.fetchData()
        //        print("allData after: \(allDataAfter)")

    }
}
