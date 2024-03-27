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
    
    private init() { 
//        deleteAllItems()
        trackers = fetchData()
    }
    
    var trackers = [TrackerCategory]()
    
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
        let allTrackers = try? context.fetch(fetchRequest)
        
        if let allTrackers = allTrackers {
            for i in allTrackers {
                context.delete(i)
            }
            save()
        }
    }

    func createNewTracker(newTracker: TrackerCategory) {
        print("We're here")
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
        
        newTrackerToAdd.category = newTrackerCategory
        
//        print("newTrackerToAdd: \(newTrackerToAdd)")
//        print("newTrackerCategory: \(newTrackerCategory)")

        save()
//        print("DataBase in CoreData: \(trackers)")
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
    
    func getDataBaseFromStorage() -> [TrackerCategory]? {
        self.trackers
    }
    
    
    
    func getCategoryNamesFromStorage() -> [String] {
        var arrayOfCategoryNames = [String]()
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        let allTrackers = try? context.fetch(fetchRequest)
        
        if let allTrackers = allTrackers {
            for i in allTrackers {
                arrayOfCategoryNames.append(i.header ?? "ЭЭ")
            }
        }
       return arrayOfCategoryNames
    }
}
