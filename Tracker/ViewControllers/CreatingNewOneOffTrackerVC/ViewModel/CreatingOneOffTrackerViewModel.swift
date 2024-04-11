//
//  CreatingOneOffTrackerViewModel.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 09.04.2024.
//

import Foundation

final class CreatingOneOffTrackerViewModel: CreatingOneOffTrackerViewModelProtocol {
    
    var tableViewRows = ["Категория"]
    
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
    
    var selectedCategory: String?
    {
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
    
    var informAnotherVCofCreatingTracker: ( () -> Void )?
    
    
    func createNewTracker() {
        guard let name = trackerName,
              let category = selectedCategory,
              let color = selectedColor,
              let emoji = selectedEmoji else {
            print("Smth going wrong here"); return
        }
        
        let newTask = TrackerCategory(header: category,
                                      trackers: [Tracker(id: UUID(),
                                                         name: name,
                                                         color: color,
                                                         emoji: emoji,
                                                         schedule: "Пн, Вт, Ср, Чт, Пт, Сб, Вс")])
        coreDataManager.createNewTracker(newTracker: newTask)
        informAnotherVCofCreatingTracker?()
    }
    
    func isAllFieldsFilled() -> Bool {
        let allFieldsFilled =
            trackerName != nil &&
            trackerName != "" &&
            selectedCategory != nil &&
            selectedEmoji != nil &&
            selectedColor != nil
        return allFieldsFilled
    }
}
