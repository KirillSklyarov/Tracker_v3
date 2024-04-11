//
//  TrackerVC+Delegates.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 09.04.2024.
//

import UIKit

extension TrackerViewController: DataProviderDelegate {
    
    func didUpdate(_ update: TrackersStoreUpdate) {
        collectionView.reloadData()
        showOrHidePlaceholder()
    }
}


extension TrackerViewController {
    @objc func closeFewVCAfterCreatingTracker() {
        viewModel.categories = viewModel.coreDataManager.fetchData()
        self.dismiss(animated: true)
    }
}
