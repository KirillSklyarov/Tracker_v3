//
//  ViewModelProtocol.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 10.04.2024.
//

import Foundation

protocol ViewModelProtocol {
    var updateCategory: ( (String) -> Void)? { get set }
    var dataUpdated: ( () -> Void )? { get set }
    var categories: [String] { get set }
    var delegateToPassCategoryNameToEdit: PassCategoryNamesToEditingVC? { get set }
    
    func getDataFromCoreData()
    func createNewCategory(newCategoryName: String)
    func deleteCategory(categoryNameToDelete: String)
    func getLastChosenCategoryFromStore() -> String
    func sendLastChosenCategoryToStore(categoryName: String)
        
}
