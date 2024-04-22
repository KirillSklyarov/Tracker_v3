//
//  TrackerCDM+Controller.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 22.04.2024.
//

import CoreData

struct TrackersStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol DataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackersStoreUpdate)
}

extension TrackerCoreManager {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.didUpdate(TrackersStoreUpdate(
            insertedIndexes: insertedIndexes!,
            deletedIndexes: deletedIndexes!
        )
        )
        insertedIndexes = nil
        deletedIndexes = nil
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {

        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}
