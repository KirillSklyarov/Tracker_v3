//
//  TrackerCoreManager.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 26.03.2024.
//

import Foundation
import CoreData
import UIKit


final class TrackerCoreManager {
    
    static let shared = TrackerCoreManager()
    
    private init() {    }
    
//    var trackers = [TrackerCategory]()
    
//    var categories = [String]()
    
    // MARK: - Continer, context
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerCoreData")
        container.loadPersistentStores { (description, error) in
            if let error = error as NSError? {
                fatalError(error.localizedDescription)
            } else {
                print("DB url: ", description.url ?? "Oooops")
            }
        }
        return container
    } ()
    
    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // MARK: - CRUD
    func fetchData() -> [TrackerCategory] {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        do {
            let allTrackers = try context.fetch(fetchRequest)
            let result = transformCoreDataToModel(TrackerСategoryCoreData: allTrackers)
            return result
        } catch  {
            print(error.localizedDescription)
            return []
        }
    }
        
    func transformCoreDataToModel(TrackerСategoryCoreData: [TrackerCategoryCoreData]) -> [TrackerCategory] {
        let trackersCategory = TrackerСategoryCoreData.compactMap({
            TrackerCategory(coreDataObject: $0)
        })
        return trackersCategory
    }
    
    func deleteOneItem(trackerCategoryCoreData: TrackerCategoryCoreData) {
        context.delete(trackerCategoryCoreData)
        save()
    }
    
    func deleteAllItems() {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        do {
            var allTrackers = try context.fetch(fetchRequest)
            allTrackers.removeAll()
            save()
            print("Data deleted ✅")
        } catch  {
            print(error.localizedDescription)
        }
    }

    
    func createNewCategory(newCategoryName: String) {
        print("We're here - createNewCategory")
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.header = newCategoryName
        save()
        print("New Category created ✅")
    }

    func createNewTracker(newTracker: TrackerCategory) {
        print("We're here - createNewTracker")
        let header = newTracker.header
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "header = %@", header)
        
        do {
            let result = try context.fetch(fetchRequest)
            if let foundCategory = result.first {
                guard let color = newTracker.trackers.first?.color else { return }
                let colorInString = color.hexStringFromUIColor()
                
                let newTrackerToAdd = TrackerCoreData(context: context)
                newTrackerToAdd.id = newTracker.trackers.first?.id
                newTrackerToAdd.name = newTracker.trackers.first?.name
                newTrackerToAdd.colorHex = colorInString
                newTrackerToAdd.emoji = newTracker.trackers.first?.emoji
                newTrackerToAdd.schedule = newTracker.trackers.first?.schedule
                
                foundCategory.addToTrackers(newTrackerToAdd)
                //                newTrackerToAdd.category = foundCategory
                save()
                print("New Tracker created and Added TO EXISTING CAT ✅")
            }
        } catch  {
            let newTrackerCategory = TrackerCategoryCoreData(context: context)
            newTrackerCategory.header = newTracker.header
            
            guard let color = newTracker.trackers.first?.color else { return }
            let colorInString = color.hexStringFromUIColor()
            
            let newTrackerToAdd = TrackerCoreData(context: context)
            newTrackerToAdd.id = newTracker.trackers.first?.id
            newTrackerToAdd.name = newTracker.trackers.first?.name
            newTrackerToAdd.colorHex = colorInString
            newTrackerToAdd.emoji = newTracker.trackers.first?.emoji
            newTrackerToAdd.schedule = newTracker.trackers.first?.schedule
            
            newTrackerCategory.addToTrackers(newTrackerToAdd)
            //            newTrackerToAdd.category = newTrackerCategory
            save()
            print("New Tracker created and Added TO NEW CAT ✅")
        }
    }
        
    
    func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do  {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
//    func getDataBaseFromStorage() -> [TrackerCategory]? {
//        self.trackers
//    }
    
    func getCategoryNamesFromStorage() -> [String] {
        var arrayOfCategoryNames = [String]()
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        let allTrackers = try? context.fetch(fetchRequest)
        
        if let allTrackers = allTrackers {
            for i in allTrackers {
                arrayOfCategoryNames.append(i.header ?? "ЭЭ")
            }
        }
        let uniqueCategoryNames = Array(Set(arrayOfCategoryNames))
        
       return uniqueCategoryNames
    }
}
