//
//  EditingViewModelProtocol.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 11.04.2024.
//

import Foundation

protocol EditingTrackerViewModelProtocol {
    
    var trackerName: String? { get set }
    var emoji: String? { get set }
    var color: String? { get set }
    var category: String? { get set }
    var schedule: String? { get set }
    
    var indexPath: IndexPath? { get set }

    var coreDataManager: TrackerCoreManager { get }
    
    var arrayOfEmoji: [String] { get set }
    var arrayOfColors: [String] { get set }
    var countOfCompletedDays: String? { get set }
    
    var tableViewRows: [String] { get set }
    
    var emojiIndexPath: IndexPath? { get }
    var colorIndexPath: IndexPath? { get }
    
    var initialTrackerCategory: String? { get }
    
    var updateSaveButton: ( () -> Void )? { get set }
    
    func createNewTracker()
    func isAllFieldsFilled() -> Bool
    func countOfDaysForTheTrackerInString(trackerId: String) -> String
    func getTrackerDataForEditing(indexPath: IndexPath)
    func updateTracker()

}
