//
//  passCategoryNameToEditingVC.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 22.03.2024.
//

import Foundation

protocol FilterCategoryDelegate: AnyObject {
    func getFilterFromPreviousVC(filter: String)
}
