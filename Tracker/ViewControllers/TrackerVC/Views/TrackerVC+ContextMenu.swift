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

        return UIContextMenuConfiguration(actionProvider: { (_) -> UIMenu? in

            let lockAction = UIAction(title: SGen.pin) { [weak self] _ in
                guard let self else { return }

                //                if stickyCollectionView.frame.contains(location) {
                //                    print("stickyCollectionView")
                //                } else  {
                //                    print("collectionView")
                //                }

                let convertedLocation = trackersCollectionView.convert(location, from: interaction.view)
                //      let convertedLocation2 = stickyCollectionView.convert(location, from: interaction.view)

                //                print("convertedLocation \(convertedLocation)")
                //                print("convertedLocation2 \(convertedLocation2)")

                //                let indexPath = trackersCollectionView.indexPathForItem(at: convertedLocation)
                //                let indexPath2 = stickyCollectionView.indexPathForItem(at: convertedLocation2)
                //                print("indexPath \(indexPath)")
                //                print("indexPath2 \(indexPath2)")

                guard let indexPath = trackersCollectionView.indexPathForItem(at: convertedLocation) else {
                    print("We have a problem with editing a tracker"); return
                }

                //                indexPath.section -= 1

                //                print("indexPath \(indexPath)")

                //                let sections = viewModel.coreDataManager.correctSectionsWithStickySectionFirst()
                //                print("sections \(sections)")

                //                indexPath.section += 1

                //    let newIndexPath = viewModel.coreDataManager.fetchedResultsController?.object(at: indexPath)
                //                print("newIndexPath \(newIndexPath)")

                guard let trackerCore = viewModel.coreDataManager.object(at: indexPath) else { print("Hmmmm"); return }
                print("trackerCore \(trackerCore)")

                //                guard let indexPath2 = stickyCollectionView.indexPathForItem(at: convertedLocation2)
                // else {
                //                    print("We have a problem with editing a tracker"); return
                //                }

                // todo чтобы закрепить трекер мы должны создать такой же трекер с категорией
                // "Закрепленные", а потом удалить трекер из этой категории

                // Тут мы создаем категорию Закрепленные и закрепляем трекер
                viewModel.coreDataManager.fixingTracker(tracker: trackerCore)

            }

            let editAction = UIAction(title: SGen.edit) { [weak self] _ in
                guard let self else { return }

                let convertedLocation = trackersCollectionView.convert(location, from: interaction.view)

                guard let indexPath = trackersCollectionView.indexPathForItem(at: convertedLocation) else {
                    print("We have a problem with editing a tracker"); return
                }

                goToEditingVC()

                self.viewModel.passTrackerToEditDelegate?.passTrackerIndexPathToEdit(indexPath: indexPath)
            }

            let deleteAction = UIAction(title: SGen.delete, attributes: .destructive) { [weak self] _ in
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
        let alert = UIAlertController(title: "Уверены, что хотите удалить трекер",
                                      message: nil,
                                      preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: SGen.delete, style: .destructive) { [weak self] _ in
            guard let self = self else { return }

            // Здесь мы находим indexPath трекера
            let convertedLocation = trackersCollectionView.convert(location, from: interaction.view)
            guard let indexPath = trackersCollectionView.indexPathForItem(at: convertedLocation) else {
                print("We have a problem with deleting a tracker"); return
            }
            // Здесь мы удаляем трекер
            viewModel.coreDataManager.deleteTracker(at: indexPath)
        }

        let cancelAction = UIAlertAction(title: SGen.cancel, style: .cancel)
        [deleteAction, cancelAction].forEach { alert.addAction($0)}
        self.present(alert, animated: true)
    }
}
