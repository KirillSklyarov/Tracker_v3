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
    
    var updateCategory: ( (String) -> Void)?
    
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
    
    func deSelectCell(cell: CustomCategoryCell) {
        cell.checkmarkImage.isHidden = true
    }
    
    func showLastChosenCategory(cell: CustomCategoryCell) {
        let lastChosenCategory = self.getLastChosenCategoryFromStore()
        if lastChosenCategory == cell.titleLabel.text {
            self.selectCell(cell: cell)
        }
    }
    
    func selectCell(cell: CustomCategoryCell) {
        cell.selectionStyle = .none
        cell.checkmarkImage.isHidden = false
    }
    
    func choosingCategory(cell: CustomCategoryCell) {
        
        self.selectCell(cell: cell)
        
        guard let categoryNameToPass = cell.titleLabel.text else {
            print("Oooops"); return }
        self.sendLastChosenCategoryToStore(categoryName: categoryNameToPass)
        self.updateCategory?(categoryNameToPass)
    }
}
