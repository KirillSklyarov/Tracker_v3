//
//  ResultController.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 28.03.2024.
//

import CoreData
import UIKit

enum EmojiMixStoreError: Error {
    case decodingErrorInvalidEmojies
    case decodingErrorInvalidColorHex
}

struct EmojiMixStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol EmojiMixStoreDelegate: AnyObject {
    func store(
        _ store: EmojiMixStore,
        didUpdate update: EmojiMixStoreUpdate
    )
}

final class EmojiMixStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!

    weak var delegate: EmojiMixStoreDelegate?
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
//    convenience override init() {
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//        try! self.init(context: context)
//    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        let sort = NSSortDescriptor(key: "category.header", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.header",
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch()
    }
}

extension EmojiMixStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: EmojiMixStoreUpdate(
                insertedIndexes: insertedIndexes!,
                deletedIndexes: deletedIndexes!
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError() }
            insertedIndexes?.insert(indexPath.item)
        case .delete:
            guard let indexPath = indexPath else { fatalError() }
            deletedIndexes?.insert(indexPath.item)
        default:
            fatalError()
        }
    }
}




//final class FetchedResultDelegate: NSObject, NSFetchedResultsControllerDelegate {
//    
//    weak var collectionView: UICollectionView?
//    
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
//    }
//    
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
//    }
//    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//                
//        guard let collectionView = collectionView else { return }
//        
//        switch type {
//        case .delete:
//            if let indexPath = indexPath {
//                if collectionView.numberOfItems(inSection: indexPath.section) == 1 {
//                    collectionView.deleteSections(IndexSet(integer: indexPath.section))
//                } else {
//                    collectionView.deleteItems(at: [indexPath])
//                }
//            }
//        case .insert:
//            if let newIndexPath = newIndexPath {
//                if  collectionView.numberOfSections <= newIndexPath.section {
//                    collectionView.insertSections(IndexSet(integer: newIndexPath.section))
//                } else {
//                    collectionView.insertItems(at: [newIndexPath])
//                }
//            }
//        default:
//            break
//        }
//    }
//}
