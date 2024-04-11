//
//  Proto.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 11.04.2024.
//

import Foundation

protocol CreatingNewTrackerViewModelProtocol {
    var isDoneButtonEnable: ( () -> Void )? { get set }

    var tableViewRows: [String] { get set }
    var selectedCategory: String? { get set }
    var arrayOfEmoji: [String] { get set }
    var arrayOfColors: [String] { get set }
    var selectedEmoji: String? { get set }
    var selectedColor: String? { get set }
    var trackerName: String? { get set }
    var selectedSchedule: String? { get set }
    
    func createNewTracker()
    func isAllFieldsFilled() -> Bool
    func getBackToMainScreen()

}
