//
//  EditingTrackerVC+Delegate.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 11.04.2024.
//

import Foundation

extension EditingTrackerViewController: PassTrackerToEditDelegate {
    func passTrackerIndexPathToEdit(indexPath: IndexPath) {
        viewModel.getTrackerDataForEditing(indexPath: indexPath)
        viewModel.indexPath = indexPath
    }
}
