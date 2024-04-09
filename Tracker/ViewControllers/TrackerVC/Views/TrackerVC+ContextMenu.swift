//
//  TVC+ContextMenu.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 09.04.2024.
//

import UIKit

// MARK: - Context Menu
extension TrackerViewController: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(actionProvider: { (_) -> UIMenu? in
            
            let lockAction = UIAction(title: "Закрепить") { _ in }
            let editAction = UIAction(title: "Редактировать") { _ in
                
                let convertedLocation = self.collectionView.convert(location, from: interaction.view)
                
                guard let indexPath = self.collectionView.indexPathForItem(at: convertedLocation) else {
                    print("We have a problem with editing a tracker"); return
                }
                
                guard let cell = self.collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell,
                      let daysCountText = cell.daysLabel.text else {
                    print("Unable to get cell for indexPath: \(indexPath)")
                    return
                }
                
                let editingVC = EditingTrackerViewController()
                self.viewModel.passTrackerToEditDelegate = editingVC
                let navVC = UINavigationController(rootViewController: editingVC)
                self.present(navVC, animated: true)
                self.viewModel.passTrackerToEditDelegate?.getTrackerToEditFromCoreData(indexPath: indexPath, labelText: daysCountText)
            }
            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { _ in
                self.showAlert(location: location, interaction: interaction)
            }
            
            let menu = UIMenu(children: [lockAction, editAction, deleteAction])
            
            return  menu
        }
        )
    }
    
    
    private func showAlert(location: CGPoint, interaction: UIContextMenuInteraction) {
        let alert = UIAlertController(title: "Уверены, что хотите удалить трекер", message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            let convertedLocation = self.collectionView.convert(location, from: interaction.view)
            
            guard let indexPath = self.collectionView.indexPathForItem(at: convertedLocation) else {
                print("We have a problem with deleting a tracker"); return
            }
            
            self.viewModel.coreDataManager.deleteAllTrackerRecordsForTracker(at: indexPath)
            self.viewModel.coreDataManager.deleteTracker(at: indexPath)
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
}
