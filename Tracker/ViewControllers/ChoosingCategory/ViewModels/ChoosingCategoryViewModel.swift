//
//  ChoosingCategoryViewModel.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 06.04.2024.
//

import Foundation

final class ChoosingCategoryViewModel: ViewModelProtocol {

    let coreDataManager = TrackerCoreManager.shared

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
        categories = coreDataManager.getCategoryNamesFromStorage()
    }

    func createNewCategory(newCategoryName: String) {
        coreDataManager.createNewCategory(newCategoryName: newCategoryName)
        getDataFromCoreData()
    }

    func deleteCategory(categoryNameToDelete: String) {
        coreDataManager.deleteCategory(header: categoryNameToDelete)
        getDataFromCoreData()
    }

    func getLastChosenCategoryFromStore() -> String {
        coreDataManager.getLastChosenCategoryFromStore()
    }

    func sendLastChosenCategoryToStore(categoryName: String) {
        coreDataManager.sendLastChosenCategoryToStore(categoryName: categoryName)
    }
}
