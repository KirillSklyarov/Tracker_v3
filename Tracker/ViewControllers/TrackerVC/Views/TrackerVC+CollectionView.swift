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

        //        stickyCollectionView.isScrollEnabled = false

        stickyCollectionView.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)

        stickyCollectionView.register(
            SupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header")
        stickyCollectionView.register(
            SupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "footer")

        stickyCollectionView.backgroundColor = AppColors.background

        // Заводим переменную чтобы потом ее обновлять без ошибок
        stickyCollectionHeightConstraint = stickyCollectionView.heightAnchor.constraint(equalToConstant: 0)
        stickyCollectionHeightConstraint?.isActive = true

    }

    func setupTrackerCollectionView() {

        trackersCollectionView.dataSource = self
        trackersCollectionView.delegate = self

        trackersCollectionView.backgroundColor = AppColors.background

        trackersCollectionView.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)

        trackersCollectionView.register(
            SupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header")
        trackersCollectionView.register(
            SupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "footer")
    }

    func setupContraints() {

        view.addSubViews([stickyCollectionView, trackersCollectionView])

        NSLayoutConstraint.activate([
            stickyCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stickyCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stickyCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            trackersCollectionView.topAnchor.constraint(equalTo: stickyCollectionView.bottomAnchor),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        setStickyCollectionHeight()

    }

    func setStickyCollectionHeight() {

        let height = calculationOfStickyCollectionHeight()
        stickyCollectionHeightConstraint?.constant = height
        print("stickyCollectionHeightConstraint \(height)")
    }

    func calculationOfStickyCollectionHeight() -> CGFloat {

        guard let collectionElements = viewModel.coreDataManager.pinnedTrackersFRC?.fetchedObjects?.count else {
            print("Nil"); return 0}
//        coreDataManager.numberOfPinnedItems()
        //                print("collectionElements \(collectionElements)")
        let numberOfRows = ceil(Double(collectionElements) / 2.0)
        //                print("numberOfRows \(numberOfRows)")
        let cellHeight = numberOfRows > 1 ? 180 : 200
        let collectionHeight = numberOfRows * Double(cellHeight)

        return collectionHeight
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == stickyCollectionView {
            return viewModel.coreDataManager.pinnedSection
        } else {
            return viewModel.coreDataManager.numberOfSections
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == stickyCollectionView {
            return viewModel.coreDataManager.numberOfPinnedTrackers(section)
        } else {
            return viewModel.coreDataManager.numberOfRowsInSection(section)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.identifier,
            for: indexPath) as? TrackerCollectionViewCell else {
            print("We have some problems with CustomCell")
            return UICollectionViewCell()
        }

        if collectionView == stickyCollectionView {
            configureStickyCollection(cell: cell, indexPath: indexPath)
        } else {
            configureTrackerCollection(cell: cell, indexPath: indexPath)
        }
        return cell
    }

    func configureStickyCollection(cell: TrackerCollectionViewCell, indexPath: IndexPath) {
        guard let pinnedTrackers = viewModel.coreDataManager.getAllPinnedTrackers() else {
            print("1We have some problems with decoding here")
            return
        }
        //        print("pinnedTrackers \(pinnedTrackers)")
        let pinnedTrackerCD = pinnedTrackers[indexPath.item]
        let pinnedTracker = Tracker(coreDataObject: pinnedTrackerCD)

        configureCell(tracker: pinnedTracker, cell: cell)
    }

    func configureTrackerCollection(cell: TrackerCollectionViewCell, indexPath: IndexPath) {
        guard let trackerCD = viewModel.coreDataManager.object(at: indexPath) else {
            print("Hmm"); return }

        let tracker = Tracker(coreDataObject: trackerCD)
        //        print("tracker \(tracker)")
        configureCell(tracker: tracker, cell: cell)
    }

    private func configureCell(tracker: Tracker,
                               cell: TrackerCollectionViewCell) {
        //        guard let trackerID = tracker.id else { print("Pam-pa-ram"); return }

        let trackerColor = UIColor(hex: tracker.color)
        let frameColor = trackerColor
        let today = Date()

        cell.titleLabel.text = tracker.name
        cell.emojiLabel.text = tracker.emoji
        cell.frameView.backgroundColor = frameColor
        cell.plusButton.backgroundColor = frameColor
        cell.plusButton.addTarget(self, action: #selector(cellButtonTapped), for: .touchUpInside)
        cell.plusButton.isEnabled = currentDate > today ? false : true

        let countOfDays = MainHelper.countOfDaysForTheTrackerInString(trackerId: tracker.id.uuidString)
        cell.daysLabel.text = countOfDays

        showPinImage(tracker: tracker, cell: cell)

        showDoneOrUndoneTaskForDatePickerDate(tracker: tracker, cell: cell)

        let interaction = UIContextMenuInteraction(delegate: self)
        cell.frameView.addInteraction(interaction)
    }

    func showPinImage(tracker: Tracker, cell: TrackerCollectionViewCell) {
        if tracker.isPinned == true {
            cell.pinImage.isHidden = false
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        var id = ""
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }

        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: id, for: indexPath) as? SupplementaryView else {
            print("We have some problems with header"); return UICollectionReusableView()
        }
        if kind == UICollectionView.elementKindSectionHeader {
            collectionsHeaders(collection: collectionView, view: view, indexPath: indexPath)
        }
        return view
    }

    func collectionsHeaders(collection: UICollectionView, view: SupplementaryView, indexPath: IndexPath) {
        if collection == stickyCollectionView {
            let header = SGen.pinned
            view.label.text = header
        } else {
            if let headers = viewModel.coreDataManager.trackersFRC?.sections {
                view.label.text = headers[indexPath.section].name
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int) -> CGSize {

            if collectionView == trackersCollectionView {
                if section == collectionView.numberOfSections - 1 {
                    return CGSize(width: collectionView.bounds.width, height: 60)
                }
            }
            return CGSize(width: 0, height: 0)
        }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2 - 9, height: 148)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        9
    }
}
