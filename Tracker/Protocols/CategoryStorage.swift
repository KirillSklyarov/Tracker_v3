//
//  Singleton.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 19.03.2024.
//

import Foundation
import UIKit

//final class CategoryStorage {
//    
//    static let shared = CategoryStorage()
//    
//    private init() { }
    
//    var categoryNames: [String] = ["First", "Second", "Third"]
    
//    var categoryNames: [String] = []

//    func addToCategoryNamesStorage(categoryNames: [String]) {
//        for categoryName in categoryNames {
//            self.categoryNames.append(categoryName)
//        }
//    }
    
//    func updateCategoryNamesInStorage(categoryNames: [String]) {
//        self.categoryNames = categoryNames
//    }
    
//    func getCategoryNamesFromStorage() -> [String] {
//        self.categoryNames
//    }
    
//    var dataBase = TrackerCoreManager.shared.trackers
    
//    func addToDataBase(dataBase: TrackerCategory) {
//        if let categoryIndex = self.dataBase.firstIndex(where: { $0.header == dataBase.header } ) {
//            let categoryHeader = dataBase.header
//            var trackerInCategory = self.dataBase[categoryIndex].trackers
//            for tracker in dataBase.trackers {
//                trackerInCategory.append(tracker)
//            }
//            self.dataBase[categoryIndex] = TrackerCategory(header: categoryHeader,
//                                                           trackers: trackerInCategory)
//        } else {
//            self.dataBase.append(dataBase)
//        }
//    }
    
//    func getDataBaseFromStorage() -> [TrackerCategory]? {
//        self.dataBase
//    }
//}
