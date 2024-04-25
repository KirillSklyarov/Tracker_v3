//
//  PassTrackerToEditDelegate.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 03.04.2024.
//

import Foundation

protocol PassTrackerToEditDelegate: AnyObject {
    func passTrackerIndexPathToEdit(tracker: TrackerCoreData, indexPath: IndexPath)
}
