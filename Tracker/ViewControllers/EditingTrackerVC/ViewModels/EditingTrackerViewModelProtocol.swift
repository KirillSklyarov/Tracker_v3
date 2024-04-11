//
//  EditingViewModelProtocol.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 11.04.2024.
//

import Foundation

protocol EditingTrackerViewModelProtocol {
    
    var newTaskName: String? { get set }
    var selectedEmoji: String? { get set }
    var selectedColor: String? { get set }
    var selectedCategory: String? { get set }
    var selectedSchedule: String? { get set }
    var coreDataManager: TrackerCoreManager { get }
    var arrayOfEmoji: [String] { get set }
    var arrayOfColors: [String] { get set }
    
    var tableViewRows: [String] { get set }
    
    var emojiIndexPath: IndexPath? { get set }
    var colorIndexPath: IndexPath? { get set }
    var categoryName: String? { get set }
    var schedule: String? { get set }
    
    
    var informAnotherVCofCreatingTracker: ( () -> Void )? { get set }

    
    
}
