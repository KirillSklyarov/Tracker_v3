//
//  EditingTrackerVC+Delegate.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 11.04.2024.
//

import Foundation

extension EditingTrackerViewController: PassTrackerToEditDelegate {
    func getTrackerToEditFromCoreData(indexPath: IndexPath, labelText: String) {
        guard let tracker = viewModel.coreDataManager.fetchedResultsController?.object(at: indexPath),
              let trackerId = tracker.id else { return }
        
//        let labelText = coreDataManager.
//        countOfTrackerInRecords(trackerIDToCount: trackerId.uuidString)
        
        self.counterLabel.text = labelText
        self.trackerNameTextField.text = tracker.name
        
        if let trackerEmoji = tracker.emoji,
           let emojiIndex = viewModel.arrayOfEmoji.firstIndex(of: trackerEmoji) {
            self.viewModel.emojiIndexPath = IndexPath(row: emojiIndex, section: 0)
        }
        
        if let trackerColor = tracker.colorHex,
           let colorIndex = viewModel.arrayOfColors.firstIndex(of: trackerColor) {
            self.viewModel.colorIndexPath = IndexPath(row: colorIndex, section: 0)
        }
        
        self.viewModel.categoryName = tracker.category?.header
        self.viewModel.schedule = tracker.schedule
        
    }
}
