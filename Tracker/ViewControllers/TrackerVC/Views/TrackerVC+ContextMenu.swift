//
//  TVC+ContextMenu.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 09.04.2024.
//

import UIKit

// MARK: - Context Menu
extension TrackerViewController: UIContextMenuInteractionDelegate {

    // MARK: - Setup ContextMenu
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {

        var chosenCollection: UICollectionView?
        let touchPoint = interaction.location(in: view)

        // Находим к какой коллекции относится трекер
        let stickyFrame = stickyCollectionView.frame
//        print("Stiky frame \(stickyFrame)")
        let trackersFrame = trackersCollectionView.frame
//        print("Trackers frame \(trackersFrame)")
        let checkSticky = stickyCollectionView.frame.contains(touchPoint)
//        print("checkSticky: \(checkSticky)")
        let checkTracker = trackersCollectionView.frame.contains(touchPoint)
//        print("checkTracker: \(checkTracker)")

        if stickyCollectionView.frame.contains(touchPoint) {
            chosenCollection = stickyCollectionView
            print("1")
        } else if trackersCollectionView.frame.contains(touchPoint) {
            chosenCollection = trackersCollectionView
            print("2")
        }

        // Здесь мы находим indexPath трекера
        guard let chosenCollection else { return nil}
        let convertedLocation = chosenCollection.convert(location, from: interaction.view)
        guard let indexPath = chosenCollection.indexPathForItem(at: convertedLocation) else {
            print("We have a problem with editing a tracker")
            return nil
        }

        return UIContextMenuConfiguration(actionProvider: { (_) -> UIMenu? in

            let menu = self.setupContextMenu(collection: chosenCollection,
                                             indexPath: indexPath)
            return menu
        }
        )
    }

    func setupContextMenu(collection: UICollectionView,
                          indexPath: IndexPath) -> UIMenu? {

        let pinAction = setupPinAction(collection: collection, indexPath: indexPath)
        let editAction = setupEditAction(collection: collection, indexPath: indexPath)
        let deleteAction = setupDeleteAction(collection: collection, indexPath: indexPath)

        let menu = UIMenu(children: [pinAction, editAction, deleteAction])

        return menu
    }

    // MARK: - Pin
    func setupPinAction(collection: UICollectionView, indexPath: IndexPath) -> UIAction {
        let title = collection == trackersCollectionView ? "Pin" : "Unpin"

        let pinAction = UIAction(title: title.localized()) { [weak self] _ in
            guard let self else { return }

            if collection == trackersCollectionView {
                viewModel.coreDataManager.pinTracker(indexPath: indexPath)
            } else {
                viewModel.coreDataManager.unpinTracker(indexPath: indexPath)
            }
        }
        return pinAction
    }

    // MARK: - Edit
    func setupEditAction(collection: UICollectionView, indexPath: IndexPath) -> UIAction {
        var tracker: TrackerCoreData?

        let editAction = UIAction(title: SGen.edit) { [weak self] _ in
            guard let self else { return }

            if collection == trackersCollectionView {
                tracker = viewModel.coreDataManager.object(at: indexPath)
            } else {
                tracker = viewModel.coreDataManager.getPinnedTrackerWithIndexPath(indexPath: indexPath)
                //                print("tracker \(tracker)")
            }

            guard let tracker else { return }

            goToEditingVC()

            self.viewModel.passTrackerToEditDelegate?.passTrackerIndexPathToEdit(tracker: tracker, indexPath: indexPath)
        }
        return editAction
    }

    private func goToEditingVC() {
        let viewModel = EditingTrackerViewModel()
        let editingVC = EditingTrackerViewController(viewModel: viewModel)
        self.viewModel.passTrackerToEditDelegate = editingVC
        let navVC = UINavigationController(rootViewController: editingVC)
        self.present(navVC, animated: true)
    }

    // MARK: - Delete
    func setupDeleteAction(collection: UICollectionView, indexPath: IndexPath) -> UIAction {
        let deleteAction = UIAction(title: SGen.delete, attributes: .destructive) { [weak self] _ in
            guard let self else { return }
            self.showAlert(collection: collection, indexPath: indexPath)
        }
        return deleteAction
    }

    private func showAlert(collection: UICollectionView, indexPath: IndexPath) {
        let alert = UIAlertController(title: SGen.areYouSureYouWantToDeleteTheTracker,
                                      message: nil,
                                      preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: SGen.delete, style: .destructive) { [weak self] _ in
            guard let self = self else { return }

            // Здесь мы удаляем трекер
            if collection == trackersCollectionView {
                viewModel.coreDataManager.deleteTracker(at: indexPath)
            } else {
                deletePinnedTracker(indexPath: indexPath)
            }
        }

        let cancelAction = UIAlertAction(title: SGen.cancel, style: .cancel)
        [deleteAction, cancelAction].forEach { alert.addAction($0)}
        self.present(alert, animated: true)
    }

    private func deletePinnedTracker(indexPath: IndexPath) {
        guard
            let tracker = viewModel.coreDataManager.getPinnedTrackerWithIndexPath(indexPath: indexPath),
            let trackerID = tracker.id?.uuidString else {
            print("Some problems")
            return
        }
        //        print("tracker \(trackerID)")
        viewModel.coreDataManager.deleteTrackerWithID(trackerID: trackerID)
    }

}
