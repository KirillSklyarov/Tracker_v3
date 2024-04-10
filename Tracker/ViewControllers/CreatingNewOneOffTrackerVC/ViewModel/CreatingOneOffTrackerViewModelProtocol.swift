//
//  Protocol.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 10.04.2024.
//

import Foundation

protocol CreatingOneOffTrackerViewModelProtocol {
    var informAnotherVCofCreatingTracker: ( () -> Void )? { get set }
    var isDoneButtonEnable: ( () -> Void )? { get set }

    var tableViewRows: [String] { get set }
    var selectedCategory: String? { get set }
    var arrayOfEmoji: [String] { get set }
    var arrayOfColors: [String] { get set }
    var selectedEmoji: String? { get set }
    var selectedColor: String? { get set }
    
    func createNewTracker(trackerNameTextField: String)
    func isAllFieldsFilled(trackerNameTextField: Bool) -> Bool

}
