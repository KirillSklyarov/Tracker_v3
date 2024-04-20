//
//  TVC+CollectionView.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 09.04.2024.
//

import UIKit

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension TrackerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func setupStickyCollectionView() {
        
        stickyCollectionView.dataSource = self
        stickyCollectionView.delegate = self
        
        stickyCollectionView.isScrollEnabled = false
        
        stickyCollectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        
        stickyCollectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        stickyCollectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
                
            
//        print("collectionElements \(collectionElements)")
//        print("collectionElements / 2 \(collectionElements / 2)")
        
        stickyCollectionView.layer.borderWidth = 1
        
        _ = calculationOfStickyCollectionHeight()
//                print("collectionHeight \(collectionHeight)")


        view.addSubViews([stickyCollectionView])
        
        NSLayoutConstraint.activate([
            stickyCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stickyCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stickyCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stickyCollectionView.heightAnchor.constraint(equalToConstant: 0)
//                collectionHeight)
        ])
    }
    
    func calculationOfStickyCollectionHeight() -> CGFloat {
        var collectionElements = viewModel.coreDataManager.numberOfRowsInStickySection()
        var collectionHeight: CGFloat  // = CGFloat(200)
        let cellHeight = 200
        
        if collectionElements % 2 != 0 {
//            cellHeight = 180
            collectionElements += 1
//            collectionHeight = Double(collectionElements / 2) * Double(cellHeight)
        } else {
//            cellHeight = 200
//            collectionHeight = Double(collectionElements + 1 / 2) * Double(cellHeight)
        }
        collectionHeight = Double(collectionElements / 2) * Double(cellHeight)

        return collectionHeight
    }

    func setupCollectionView() {
        
        trackersCollectionView.dataSource = self
        trackersCollectionView.delegate = self
        
        trackersCollectionView.backgroundColor = AppColors.background
        
        trackersCollectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        
        trackersCollectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        trackersCollectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
        
        view.addSubViews([trackersCollectionView])
        
        NSLayoutConstraint.activate([
            trackersCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == stickyCollectionView {
            return 0
        } else {
           return viewModel.coreDataManager.numberOfSections
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        if collectionView == stickyCollectionView {
        //            print(" Trackers in Sticky \(viewModel.coreDataManager.numberOfRowsInStickySection())")
        
        //            return 0
        //            viewModel.coreDataManager.numberOfRowsInStickySection()
        //        } else {
        //            print(section)
        //            print(viewModel.coreDataManager.numberOfRowsInSection(section))
        return viewModel.coreDataManager.numberOfRowsInSection(section)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as? TrackerCollectionViewCell else { print("We have some problems with CustomCell");
            return UICollectionViewCell()
        }
        
//        guard let object = viewModel.coreDataManager.getObjectWithStickyCategory(indexPath: indexPath) as? TrackerCoreData else {
//            print("We have some problems with decoding here")
//            return UICollectionViewCell()
//        }
         
//        print("object: \(object)")
        
        guard let object = viewModel.coreDataManager.object(at: indexPath) else {
                    print("We have some problems with decoding here")
                    return UICollectionViewCell()
                }
        
        
        configureCell(tracker: object, cell: cell, indexPath: indexPath)
        
        return cell
    }
    
    private func configureCell(tracker: TrackerCoreData,  cell: TrackerCollectionViewCell, indexPath: IndexPath) {
        guard let trackerID = tracker.id else { print("Pam-pa-ram"); return }
        
        let trackerColor = UIColor(hex: tracker.colorHex ?? "#000000")
        let frameColor = trackerColor
        let today = Date()
        
        cell.titleLabel.text = tracker.name
        cell.emojiLabel.text = tracker.emoji
        cell.frameView.backgroundColor = frameColor
        cell.plusButton.backgroundColor = frameColor
        cell.plusButton.addTarget(self, action: #selector(cellButtonTapped), for: .touchUpInside)
        cell.plusButton.isEnabled = currentDate > today ? false : true
        
        let countOfDays = MainHelper.countOfDaysForTheTrackerInString(trackerId: trackerID.uuidString)
        cell.daysLabel.text = countOfDays

        showDoneOrUndoneTaskForDatePickerDate(tracker: tracker, cell: cell)
        
        let interaction = UIContextMenuInteraction(delegate: self)
        cell.frameView.addInteraction(interaction)
    }
    
//    func showPinForStickyTrackers(cell: TrackerCollectionViewCell, indexPath: IndexPath) {
//        guard let section = viewModel.coreDataManager.correctSectionsWithStickySectionFirst() else { print("Jopa"); return }
//        let categoryName = section[indexPath.section].name
//        
//        if categoryName == "Закрепленные" {
//            cell.pinImage.isHidden = false
//        }
//    }
    
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
        if collectionView == stickyCollectionView {
            let header = "Закрепленные"
            view.label.text = header
        } else {
            if let headers = viewModel.coreDataManager.fetchedResultsController?.sections  {
                view.label.text = headers[indexPath.section].name
            }
        }
        
//        guard let headers = viewModel.coreDataManager.correctSectionsWithStickySectionFirst() else { print("Shit"); return UICollectionReusableView()}
//        view.label.text = headers[indexPath.section].name
        
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
