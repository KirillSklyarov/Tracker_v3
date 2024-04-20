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
        
        let newTask = TrackerCategory(header: category,
                                      trackers: [Tracker(id: UUID(),
                                                         name: name,
                                                         color: color,
                                                         emoji: emoji,
                                                         schedule: schedule)])
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
    
    func getTrackerDataForEditing(indexPath: IndexPath) {
        guard let tracker = coreDataManager.object(at: indexPath),
              let trackerID = tracker.id else { return }
        let countOfDays = MainHelper.countOfDaysForTheTrackerInString(trackerId: trackerID.uuidString)
        
        trackerName = tracker.name
        category = tracker.category?.header
        schedule = tracker.schedule
        emoji = tracker.emoji
        color = tracker.colorHex
        countOfCompletedDays = countOfDays
        
        initialTrackerCategory = tracker.category?.header
    }
    
    func updateTracker() {
        guard let indexPath,
              let tracker = coreDataManager.object(at: indexPath) else { return }

        if isCategoryChanged() {
           changeTrackerCategory(tracker: tracker, indexPath: indexPath)
        } else {
            saveCorrectedTracker(tracker: tracker)
        }
    }
    
    func isCategoryChanged() -> Bool {
        return category != initialTrackerCategory
    }
    
    func saveCorrectedTracker(tracker: TrackerCoreData) {
        let allDataBefore = coreDataManager.fetchData()
        print("allData before: \(allDataBefore)")
        
        tracker.name = trackerName
        tracker.category?.header = category
        tracker.schedule = schedule
        tracker.emoji = emoji
        tracker.colorHex = color
        
        coreDataManager.save()
        
        let allDataAfter = coreDataManager.fetchData()
        print("allData after: \(allDataAfter)")
        
        print("Tracker updated successfully ✅")
    }
    
    func changeTrackerCategory(tracker: TrackerCoreData, indexPath: IndexPath) {
        guard let category,
              let id = tracker.id,
              let name = tracker.name,
              let colorHex = tracker.colorHex,
              let emoji = tracker.emoji,
              let schedule = tracker.schedule else {
            print("Hmmmm, bad thing"); return
        }
        
        let trackerWithAnotherCategory = TrackerCategory(header: category, 
        trackers: [Tracker(
                            id: id,
                            name: name,
                            color: colorHex,
                            emoji: emoji,
                            schedule: schedule)
        ])
        
        print(trackerWithAnotherCategory)
        
        coreDataManager.createNewTracker(newTracker: trackerWithAnotherCategory)
        
        coreDataManager.deleteTrackerFromCategory(categoryName: initialTrackerCategory!, trackerIDToDelete: id)
        
        let allDataAfter = coreDataManager.fetchData()
        print("allData after: \(allDataAfter)")
        
    }
}
