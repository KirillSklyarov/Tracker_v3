//
//  TrackerCoreData+CoreDataProperties.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 26.03.2024.
//
//

import Foundation
import CoreData


@objc(TrackerCoreData)
public class TrackerCoreData: NSManagedObject {

}

extension TrackerCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCoreData> {
        return NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }

    @NSManaged public var colorHex: String?
    @NSManaged public var emoji: String?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var schedule: String?
    @NSManaged public var category: TrackerCategoryCoreData?

}

extension TrackerCoreData : Identifiable {

}
