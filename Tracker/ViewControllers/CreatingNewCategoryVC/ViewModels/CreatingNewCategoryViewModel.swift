//
//  CreatingNewCategoryViewModel.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 08.04.2024.
//

import Foundation

final class CreatingNewCategoryViewModel {
    
    var updateTableClosure: ( (String) -> Void )?
    
    func callClosure(newCategoryName: String) {
        updateTableClosure?(newCategoryName)
    }

    
}
