//
//  StorageManager.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 24.03.2024.
//

import UIKit
import CoreData

public final class TrackerRecordStore {
    
    static let shared = TrackerRecordStore()
    
    private init() {}
    
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
}
