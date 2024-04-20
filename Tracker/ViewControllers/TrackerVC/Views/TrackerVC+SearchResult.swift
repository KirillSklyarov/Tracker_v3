//
//  TVC+SearchResult.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 09.04.2024.
//

import UIKit

// MARK: - UISearchResultsUpdating
extension TrackerViewController: UISearchResultsUpdating {
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = SGen.search
//        NSLocalizedString("Search", comment: "")
        
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchBarText = searchController.searchBar.text?.lowercased(),
           !searchBarText.isEmpty {
            viewModel.filteredData = viewModel.categories.map { category in
                let filteredTrackers = category.trackers.filter { $0.name.lowercased().contains(searchBarText) }
                return TrackerCategory(header: category.header, trackers: filteredTrackers)
            }
            viewModel.filteredData = viewModel.filteredData.filter({ !$0.trackers.isEmpty })
        } else {
            viewModel.filteredData = viewModel.categories
        }
        trackersCollectionView.reloadData()
        showOrHidePlaceholder()
    }
}
