//
//  EditingTrackerVC+Delegate.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 11.04.2024.
//

import Foundation

extension EditingTrackerViewController: PassTrackerToEditDelegate {
    func passTrackerIndexPathToEdit(tracker: TrackerCoreData, indexPath: IndexPath) {
        viewModel.getTrackerDataForEditing(tracker: tracker)
        viewModel.indexPath = indexPath
    }
}
