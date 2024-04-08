//
//  EditingCategoryVC+Delegate.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 08.04.2024.
//

import Foundation

 // MARK: - Delegate
extension EditingCategoryViewController: PassCategoryNamesToEditingVC {
    func getCategoryNameFromPreviousVC(categoryName: String) {
        viewModel.categoryHeader = categoryName
        categoryNameTextField.text = categoryName
    }
}
