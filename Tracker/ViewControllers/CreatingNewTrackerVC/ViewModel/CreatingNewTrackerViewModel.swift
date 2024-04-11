//
//  CreatingNewTrackerViewModel.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 09.04.2024.
//

import Foundation

final class CreatingNewTrackerViewModel: CreatingNewTrackerViewModelProtocol {
   
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
            isDoneButtonEnable?()
        }
    }
    
    var selectedEmoji: String? {
        didSet {
            isDoneButtonEnable?()
        }
    }
    
    var selectedColor: String? {
        didSet {
            isDoneButtonEnable?()
        }
    }
    
    var selectedCategory: String? {
        didSet {
            isDoneButtonEnable?()
        }
    }
    
    var selectedSchedule: String? {
        didSet {
            isDoneButtonEnable?()
        }
    }
    
    var isDoneButtonEnable: ( () -> Void )?
        
    func getBackToMainScreen() {
        let cancelCreatingTrackerNotification = Notification.Name("cancelCreatingTracker")
        NotificationCenter.default.post(name: cancelCreatingTrackerNotification, object: nil)
    }
    
    func createNewTracker() {
        guard let name = trackerName,
              let category = selectedCategory,
              let color = selectedColor,
              let emoji = selectedEmoji,
              let schedule = selectedSchedule else {
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
            selectedCategory != nil &&
            selectedSchedule != nil &&
            selectedEmoji != nil &&
            selectedColor != nil
        return allFieldsFilled
    }
}
