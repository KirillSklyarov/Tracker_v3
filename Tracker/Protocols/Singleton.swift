//
//  Singleton.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 19.03.2024.
//

import Foundation

final class Singeton {
    
    static let shared = Singeton()
    
    private init() { }
    
    var categoryNames: [String]?
    
    func getCategoryNames(categoryNames: [String]) {
        self.categoryNames = categoryNames
    }
    
    func sendCategoryNames() -> [String] {
        self.categoryNames ?? ["Oooopssss"]
    }
    
    
    
}
