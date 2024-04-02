//
//  TrackerCategoryCoreData+CoreDataProperties.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 01.04.2024.
//
//

import Foundation
import CoreData

@objc(TrackerCategoryCoreData)
public class TrackerCategoryCoreData: NSManagedObject {
    
    @NSManaged public var header: String?
    @NSManaged public var trackers: NSSet?
    
    @objc(addTrackersObject:)
    @NSManaged public func addToTrackers(_ value: TrackerCoreData)
    
    @objc(removeTrackersObject:)
    @NSManaged public func removeFromTrackers(_ value: TrackerCoreData)
    
    @objc(addTrackers:)
    @NSManaged public func addToTrackers(_ values: NSSet)
    
    @objc(removeTrackers:)
    @NSManaged public func removeFromTrackers(_ values: NSSet)
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCategoryCoreData> {
        return NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
    }
    
}
