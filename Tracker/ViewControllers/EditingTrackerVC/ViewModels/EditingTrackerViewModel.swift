//
//  EditingViewModel.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 11.04.2024.
//

import Foundation

final class EditingTrackerViewModel: EditingTrackerViewModelProtocol {
    
    
    var tableViewRows = ["Категория", "Расписание"]
    
    var arrayOfEmoji = ["🙂","😻","🌺","🐶","❤️","😱",
                        "😇","😡","🥶","🤔","🙌","🍔",
                        "🥦","🏓","🥇","🎸","🏝️","😪",]
    
    var arrayOfColors = ["#FD4C49", "#FF881E", "#007BFA", "#6E44FE", "#33CF69", "#E66DD4",
                         "#F9D4D4", "#34A7FE", "#46E69D", "#35347C", "#FF674D", "#FF99CC",
                         "#F6C48B", "#7994F5", "#832CF1", "#AD56DA", "#8D72E6", "#2FD058"]
    
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
    
    func countOfDaysForTheTrackerInString(trackerId: String) -> String {
        let trackerCount = coreDataManager.countOfTrackerInRecords(trackerIDToCount: trackerId)
        let correctDaysInRussian = daysLetters(count: trackerCount)
        return correctDaysInRussian
    }
    
    func daysLetters(count: Int) -> String {
        if count % 10 == 1 && count % 100 != 11 {
            return "\(count) день"
        } else if [2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 10) {
            return "\(count) дня"
        } else {
            return "\(count) дней"
        }
    }
    
    func getTrackerDataForEditing(indexPath: IndexPath) {
        guard let tracker = coreDataManager.object(at: indexPath),
              let trackerID = tracker.id else { return }
        let countOfDays = countOfDaysForTheTrackerInString(trackerId: trackerID.uuidString)
        
        trackerName = tracker.name
        category = tracker.category?.header
        schedule = tracker.schedule
        emoji = tracker.emoji
        color = tracker.colorHex
        countOfCompletedDays = countOfDays
    }
    
    func updateTracker() {
        guard let indexPath,
              let tracker = coreDataManager.object(at: indexPath) else { return }
        print("trackerName \(trackerName)")
        tracker.name = trackerName
        tracker.category?.header = category
        tracker.schedule = schedule
        tracker.emoji = emoji
        tracker.colorHex = color
        
        coreDataManager.save()
        print("Tracker updated successfully ✅")
    }
    
}
