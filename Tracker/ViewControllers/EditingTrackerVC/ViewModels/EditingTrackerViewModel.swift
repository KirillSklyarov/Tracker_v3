//
//  EditingViewModel.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 11.04.2024.
//

import Foundation

final class EditingTrackerViewModel: EditingTrackerViewModelProtocol {
    
    var tableViewRows = ["Категория", "Расписание"]
    
    var arrayOfEmoji = ["🙂","😻","🌺","🐶","❤️","😱","😇","😡","🥶","🤔","🙌","🍔","🥦","🏓","🥇","🎸","🏝️","😪",]
    
    var arrayOfColors = ["#FD4C49", "#FF881E", "#007BFA", "#6E44FE", "#33CF69", "#E66DD4", "#F9D4D4", "#34A7FE", "#46E69D", "#35347C", "#FF674D", "#FF99CC", "#F6C48B", "#7994F5", "#832CF1", "#AD56DA", "#8D72E6", "#2FD058"]
    
    let coreDataManager = TrackerCoreManager.shared
    
    var newTaskName: String?
    var selectedEmoji: String?
    var selectedColor: String?
    var selectedCategory: String?
    var selectedSchedule: String?
        
    var informAnotherVCofCreatingTracker: ( () -> Void )?
    
    var emojiIndexPath: IndexPath?
    var colorIndexPath: IndexPath?
    var categoryName: String?
    var schedule: String?
    
}
