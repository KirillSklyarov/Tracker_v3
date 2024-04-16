//
//  FilterViewModelProtocol.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 16.04.2024.
//

import Foundation

protocol FilterViewModelProtocol {
    
    var selectedFilter: String { get set }
    
    func sendLastFilterToCoreData(filter: String)
    
    func getLastFilterFromCoreData()
    
}
