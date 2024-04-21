//
//  FilterViewModel.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 16.04.2024.
//

import Foundation

final class FilterViewModel: FilterViewModelProtocol {

    let trackerCoreManager = TrackerCoreManager.shared

    var selectedFilter = String()

    func sendLastFilterToCoreData(filter: String) {
        trackerCoreManager.sendLastChosenFilterToStore(filterName: filter)
    }

    func getLastFilterFromCoreData() {
        selectedFilter = trackerCoreManager.getLastChosenFilterFromStore()
    }
}
