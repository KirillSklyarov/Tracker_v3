//
//  TrackerRecordCoreData+CoreDataProperties.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 01.04.2024.
//
//

import Foundation
import CoreData

@objc(TrackerRecordCoreData)
public class TrackerRecordCoreData: NSManagedObject {

    @NSManaged public var date: String?
    @NSManaged public var id: UUID?
    @NSManaged public var tracker: TrackerCoreData?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerRecordCoreData> {
        return NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
    }
}
