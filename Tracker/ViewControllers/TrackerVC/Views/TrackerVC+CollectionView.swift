//
//  TVC+CollectionView.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 09.04.2024.
//

import UIKit

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension TrackerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func setupCollectionView() {
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
        
        view.addSubViews([collectionView])
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.coreDataManager.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.coreDataManager.numberOfRowsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as? TrackerCollectionViewCell else { print("We have some problems with CustomCell");
            return UICollectionViewCell()
        }
        
        configureCell(cell: cell, indexPath: indexPath)
        
        return cell
    }
    
    private func configureCell(cell: TrackerCollectionViewCell, indexPath: IndexPath) {
        guard let tracker = viewModel.coreDataManager.object(at: indexPath),
              let trackerID = tracker.id else { return }
        
        let trackerColor = UIColor(hex: tracker.colorHex ?? "#000000")
        let frameColor = trackerColor
        let today = Date()
        
        cell.titleLabel.text = tracker.name
        cell.emojiLabel.text = tracker.emoji
        cell.frameView.backgroundColor = frameColor
        cell.plusButton.backgroundColor = frameColor
        cell.plusButton.addTarget(self, action: #selector(cellButtonTapped), for: .touchUpInside)
        cell.plusButton.isEnabled = currentDate > today ? false : true
        
        let trackerCount = viewModel.coreDataManager.countOfTrackerInRecords(trackerIDToCount: trackerID.uuidString)
        let correctDaysInRussian = viewModel.daysLetters(count: trackerCount)
        cell.daysLabel.text = correctDaysInRussian
        
        showDoneOrUndoneTaskForDatePickerDate(tracker: tracker, cell: cell)
        
        let interaction = UIContextMenuInteraction(delegate: self)
        cell.frameView.addInteraction(interaction)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id = ""
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? SupplementaryView else {
            print("We have some problems with header"); return UICollectionReusableView()
        }
        
        if let headers = viewModel.coreDataManager.fetchedResultsController?.sections  {
            view.label.text = headers[indexPath.section].name
        }
        return view
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2 - 9, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        9
    }
}

