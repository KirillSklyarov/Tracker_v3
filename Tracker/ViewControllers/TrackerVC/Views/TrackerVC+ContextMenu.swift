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
            let editAction = UIAction(title: "Редактировать") { [weak self] _ in
                guard let self else { return }
                
                let convertedLocation = collectionView.convert(location, from: interaction.view)
                
                guard let indexPath = collectionView.indexPathForItem(at: convertedLocation) else {
                    print("We have a problem with editing a tracker"); return
                }
                
                goToEditingVC()
                
                self.viewModel.passTrackerToEditDelegate?.passTrackerIndexPathToEdit(indexPath: indexPath)
            }
            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                self?.showAlert(location: location, interaction: interaction)
            }
            
            let menu = UIMenu(children: [lockAction, editAction, deleteAction])
            
            return  menu
        }
        )
    }
    
    private func goToEditingVC() {
        let viewModel = EditingTrackerViewModel()
        let editingVC = EditingTrackerViewController(viewModel: viewModel)
        self.viewModel.passTrackerToEditDelegate = editingVC
        let navVC = UINavigationController(rootViewController: editingVC)
        self.present(navVC, animated: true)
    }
    
    private func showAlert(location: CGPoint, interaction: UIContextMenuInteraction) {
        let alert = UIAlertController(title: "Уверены, что хотите удалить трекер", message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            // Здесь мы находим indexPath трекера
            let convertedLocation = collectionView.convert(location, from: interaction.view)
            guard let indexPath = collectionView.indexPathForItem(at: convertedLocation) else {
                print("We have a problem with deleting a tracker"); return
            }
            // Здесь мы удаляем трекер
            viewModel.coreDataManager.deleteTracker(at: indexPath)
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        [deleteAction, cancelAction].forEach { alert.addAction($0)}
        self.present(alert, animated: true)
    }
}
