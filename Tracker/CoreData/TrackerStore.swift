//
//  StorageManager.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 24.03.2024.
//

import UIKit
import CoreData

public final class TrackerStore {
    
    static let shared = TrackerStore()
    
    private init() {}
    
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
}
