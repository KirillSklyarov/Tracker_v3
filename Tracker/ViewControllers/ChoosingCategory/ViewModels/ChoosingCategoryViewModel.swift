//
//  ChoosingCategoryViewModel.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 06.04.2024.
//

import Foundation

final class ChoosingCategoryViewModel {
    
    let coreDataManager = TrackerCoreManager.shared
    
    let rowHeight = CGFloat(75)
    
    var categories = [String]() {
        didSet {
            dataUpdated?()
        }
    }
    
    var dataUpdated: ( () -> Void )?
    
    var delegateToPassCategoryNameToEdit: PassCategoryNamesToEditingVC?
    
    // MARK: - Update data from Core Data
    
    func getDataFromCoreData() {
        self.categories = coreDataManager.getCategoryNamesFromStorage()
    }
    
    func createNewCategory(newCategoryName: String) {
        coreDataManager.createNewCategory(newCategoryName: newCategoryName)
    }

    
    func deleteCategory(categoryNameToDelete: String) {
        coreDataManager.deleteCategory(header: categoryNameToDelete)
    }
    
    func getLastChosenCategoryFromStore() -> String {
        coreDataManager.getLastChosenCategoryFromStore()
    }
    
    func sendLastChosenCategoryToStore(categoryName: String) {
        coreDataManager.sendLastChosenCategoryToStore(categoryName: categoryName)
    }
}




// MARK: - Update data from Core Data
//extension ChoosingCategoryViewController {
//
//    func getDataFromCoreData() {
//        self.categories = coreDataManager.getCategoryNamesFromStorage()
//        self.categoryTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
//    }
//}
