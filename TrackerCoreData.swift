//
//  TrackerCoreData+CoreDataProperties.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 01.04.2024.
//
//

import Foundation
import CoreData

@objc(TrackerCoreData)
public class TrackerCoreData: NSManagedObject {
    
    @NSManaged public var colorHex: String?
    @NSManaged public var emoji: String?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var schedule: String?
    @NSManaged public var category: TrackerCategoryCoreData?
    @NSManaged public var trackerRecord: TrackerRecordCoreData?
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCoreData> {
        return NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }
}
