//
//  TrackerVC+ScrollView.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 24.04.2024.
//

import UIKit

// MARK: - setupScrollView
extension TrackerViewController {

    func setupScrollView() {

        let screenScrollView = UIScrollView()

        view.addSubViews([screenScrollView])

        NSLayoutConstraint.activate([
            screenScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            screenScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            screenScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            screenScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        let contentView = UIView()

        screenScrollView.addSubViews([contentView])

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: screenScrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: screenScrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: screenScrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: screenScrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: screenScrollView.widthAnchor)
        ])

        contentView.addSubViews([contentStackView])

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        setupContentStack()

    }

    func setupContentStack() {

        [stickyCollectionView, trackersCollectionView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false
        }

        [stickyCollectionView, trackersCollectionView].forEach { contentStackView.addArrangedSubview($0) }

        calculateScrollViewHeight()

    }

    func calculateScrollViewHeight() {

        stickyCollectionHeightConstraint = stickyCollectionView.heightAnchor.constraint(equalToConstant: 0)
        stickyCollectionHeightConstraint?.isActive = true

        trackerCollectionHeightConstraint = trackersCollectionView.heightAnchor.constraint(equalToConstant: 0)
        trackerCollectionHeightConstraint?.isActive = true

        scrollViewHeightConstraint = contentStackView.heightAnchor.constraint(equalToConstant: 0)

        trackersCollectionView.layoutIfNeeded()
        stickyCollectionView.layoutIfNeeded()

        let stickyCollectionHeight = stickyCollectionView.contentSize.height
        let trackerCollectionHeight = trackersCollectionView.contentSize.height
        let contentHeight = trackerCollectionHeight + stickyCollectionHeight
        print("stickyCollectionHeight \(stickyCollectionHeight)")
        print("trackerCollectionHeight \(trackerCollectionHeight)")
        print("contentHeight \(contentHeight)")

        stickyCollectionHeightConstraint?.constant = stickyCollectionHeight
        trackerCollectionHeightConstraint?.constant = trackerCollectionHeight

//        scrollViewHeightConstraint?.constant = contentHeight
//        scrollViewHeightConstraint?.isActive = true

        stickyCollectionView.layer.borderWidth = 1
        stickyCollectionView.layer.borderColor = AppColors.buttonRed?.cgColor
        trackersCollectionView.layer.borderWidth = 1
        trackersCollectionView.layer.borderColor = AppColors.buttonBlack?.cgColor

        //        contentStackView.layer.borderWidth = 1
        //        contentStackView.layer.borderColor = AppColors.filterButton?.cgColor

    }
}
