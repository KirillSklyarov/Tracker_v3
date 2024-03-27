//
//  FetchedResultsController.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 27.03.2024.
//

import Foundation
import CoreData

//final class FetchedResultsController: NSObject {
//        
//    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
//    
//    func setupFetchedResultsController(for context: NSManagedObjectContext) {
//        let request = TrackerCategoryCoreData.fetchRequest()
//        let sort = NSSortDescriptor(key: "header", ascending: true)
//        request.sortDescriptors = [sort]
//        
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
//                                                              managedObjectContext: context,
//                                                              sectionNameKeyPath: nil,
//                                                              cacheName: nil)
//        
//        fetchedResultsController?.delegate = self
//    }
//}
//
//extension FetchedResultsController: NSFetchedResultsControllerDelegate {
//    
//    
//}
