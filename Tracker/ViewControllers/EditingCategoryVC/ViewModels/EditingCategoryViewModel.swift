//
//  EditingCategoryViewModel.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 08.04.2024.
//

import Foundation

final class EditingCategoryViewModel {

    let coreDataManager = TrackerCoreManager.shared

    var updateCategoryNameClosure: ( () -> Void )?

    var categoryHeader = String() {
        didSet {
            categoryNameClosure?(categoryHeader)
        }
    }

    var categoryNameClosure: ( (String) -> Void )?

    func doneButtonTapped(newCategoryHeader: String) {
        coreDataManager.renameCategory(header: self.categoryHeader, newHeader: newCategoryHeader)
        let renameCategoryNotification = Notification.Name("renameCategory")
        NotificationCenter.default.post(name: renameCategoryNotification, object: nil)
        updateCategoryNameClosure?()
    }
}
