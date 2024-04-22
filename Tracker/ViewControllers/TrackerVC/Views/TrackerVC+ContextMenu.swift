//
//  TVC+ContextMenu.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 09.04.2024.
//

import UIKit

// MARK: - Context Menu
extension TrackerViewController: UIContextMenuInteractionDelegate {

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {

        var whichCollection: UICollectionView?
        let touchPoint = interaction.location(in: view)
        var pinUnpinLabel = ""

        // Находим к какой коллекции относится трекер
        if stickyCollectionView.frame.contains(touchPoint) {
            whichCollection = stickyCollectionView
            pinUnpinLabel = "Unpin"
        } else if trackersCollectionView.frame.contains(touchPoint) {
            whichCollection = trackersCollectionView
            pinUnpinLabel = "Pin"
        }

        // Здесь мы находим indexPath трекера
        guard let whichCollection else { return nil}
        let convertedLocation = whichCollection.convert(location, from: interaction.view)
        guard let indexPath = whichCollection.indexPathForItem(at: convertedLocation) else {
            print("We have a problem with editing a tracker")
            return nil
        }

        return UIContextMenuConfiguration(actionProvider: { (_) -> UIMenu? in

            let menu = self.setupContextMenu(indexPath: indexPath, pinUnpinLabel: pinUnpinLabel)
            return menu
        }
        )
    }

    func setupContextMenu(indexPath: IndexPath, pinUnpinLabel: String) -> UIMenu? {

        let pinAction = setupPinAction(indexPath: indexPath, pinUnpinLabel: pinUnpinLabel)
        let editAction = setupEditAction(indexPath: indexPath)
        let deleteAction = setupDeleteAction(indexPath: indexPath)

        let menu = UIMenu(children: [pinAction, editAction, deleteAction])

        return menu
    }

    func setupPinAction(indexPath: IndexPath, pinUnpinLabel: String) -> UIAction {

        let pinAction = UIAction(title: pinUnpinLabel.localized()) { [weak self] _ in
            guard let self else { return }
            viewModel.coreDataManager.pinTracker(indexPath: indexPath)
        }
        return pinAction
    }

    func setupEditAction(indexPath: IndexPath) -> UIAction {
        let editAction = UIAction(title: SGen.edit) { [weak self] _ in
            guard let self else { return }

            goToEditingVC()

            self.viewModel.passTrackerToEditDelegate?.passTrackerIndexPathToEdit(indexPath: indexPath)
        }
        return editAction
    }

    func setupDeleteAction(indexPath: IndexPath) -> UIAction {
        let deleteAction = UIAction(title: SGen.delete, attributes: .destructive) { [weak self] _ in
            guard let self else { return }
            self.showAlert(indexPath: indexPath)
        }
        return deleteAction
    }

    private func goToEditingVC() {
        let viewModel = EditingTrackerViewModel()
        let editingVC = EditingTrackerViewController(viewModel: viewModel)
        self.viewModel.passTrackerToEditDelegate = editingVC
        let navVC = UINavigationController(rootViewController: editingVC)
        self.present(navVC, animated: true)
    }

    private func showAlert(indexPath: IndexPath) {
        let alert = UIAlertController(title: SGen.areYouSureYouWantToDeleteTheTracker,
                                      message: nil,
                                      preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: SGen.delete, style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            // Здесь мы удаляем трекер
            self.viewModel.coreDataManager.deleteTracker(at: indexPath)
        }

        let cancelAction = UIAlertAction(title: SGen.cancel, style: .cancel)
        [deleteAction, cancelAction].forEach { alert.addAction($0)}
        self.present(alert, animated: true)
    }
}
