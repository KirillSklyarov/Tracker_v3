//
//  ViewController.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 12.03.2024.
//

import UIKit

final class TrackerViewController: UIViewController {
    
    // MARK: - UI Properties
    private let swooshImage = UIImageView()
    private let textLabel = UILabel()
    let searchController = UISearchController(searchResultsController: nil)
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    let datePicker = UIDatePicker()
    
    lazy var dateButton: UIButton = {
        let button = UIButton()
        let date = viewModel.dateToString(date: datePicker.date)
        button.setTitle(date, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 77, height: 34)
        button.backgroundColor = UIColor(named: "textFieldBackgroundColor")
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
        return button
    } ()
    
    lazy var filtersButton: UIButton = {
        let button = UIButton()
        button.setTitle("Фильтры", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "filterButtonBackground")
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    } ()
    
    // MARK: - Private Properties
    let viewModel = TrackerViewModel()
    
    lazy var currentDate = datePicker.date
    
    var weekDay: String {
        viewModel.getWeekdayFromCurrentDate(currentDate: currentDate)
    }
    
    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.updateDataFromCoreData(weekDay: weekDay)
                
        viewModel.coreDataManager.delegate = self
        
        setupUI()
        
        setupNotification()
        
        addTapGestureToHideDatePicker()
        
    }
    
    // MARK: - UI Actions
    @objc private func addNewHabitButtonTapped(_ sender: UIButton) {
        let creatingNewHabitVC = ChoosingTypeOfTrackerViewController()
        let creatingNavi = UINavigationController(rootViewController: creatingNewHabitVC)
        present(creatingNavi, animated: true)
        creatingNewHabitVC.closeScreenDelegate = self
    }
    
    @objc private func updateDataWithNewCategoryNames(notification: Notification) {
        viewModel.coreDataManager.setupFetchedResultsController(weekDay: weekDay)
        collectionView.reloadData()
    }
    
    @objc func cellButtonTapped(_ sender: UIButton) {
        let buttonIndexPath = sender.convert(CGPoint.zero, to: self.collectionView)
        
        guard let indexPath = collectionView.indexPathForItem(at: buttonIndexPath),
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell,
              let cellColor = cell.frameView.backgroundColor else { return }
        
        let trackerRecord = viewModel.isTrackerExistInTrackerRecord(indexPath: indexPath, date: currentDate)
        
        makeTrackerDoneOrUndone(trackerRecord: trackerRecord, cellColor: cellColor, cell: cell)
    }
    
    @objc private func dateButtonTapped(_ sender: UIButton) {
        setupDatePicker()
    }
    
    @objc private func datePickerTapped(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        currentDate = selectedDate
        let date = viewModel.dateToString(date: selectedDate)
        dateButton.setTitle(date, for: .normal)
        
        sender.removeFromSuperview()
        
        viewModel.dataUpdated = { [weak self] in
            guard let self else { return }
            self.collectionView.reloadData()
            self.showOrHidePlaceholder()
            self.navigationItem.searchController = self.searchController
        }
        
        viewModel.updateDataFromCoreData(weekDay: weekDay)
    }
    
    @objc private func filterButtonTapped(_ sender: UIButton) {
        let filterVC = FilterTrackersViewController()
        let navVC = UINavigationController(rootViewController: filterVC)
        filterVC.filterDelegate = self
        present(navVC, animated: true)
    }
    
    // MARK: - UI, Navigation, Search
    private func setupNavigation() {
        
        navigationItem.hidesSearchBarWhenScrolling = false
        
        let image = UIImage(systemName: "plus")?.withRenderingMode(.alwaysOriginal)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dateButton)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image?.withTintColor(.black), style: .done, target: self, action: #selector(addNewHabitButtonTapped))
    }
            
    private func setupFiltersButton() {
        view.addSubViews([filtersButton])
        
        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    private func setupUI() {
        
        setupNavigation()
        
        setupSearchController()
        
        setupCollectionView()
        
        setupFiltersButton()
        
        view.backgroundColor = .systemBackground
        
        showOrHidePlaceholder()
    }
    
    private func setupDatePicker() {
        datePicker.isHidden = false
        datePicker.datePickerMode = .date
        datePicker.layer.backgroundColor = UIColor.white.cgColor
        datePicker.layer.cornerRadius = 13
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        } else {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.addTarget(self, action: #selector(datePickerTapped), for: .valueChanged)
        
        navigationItem.searchController = nil
        
        view.addSubViews([datePicker])
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            datePicker.heightAnchor.constraint(greaterThanOrEqualToConstant: 325)
        ])
    }
    
    
    // MARK: - Private Methods
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateDataWithNewCategoryNames), name: Notification.Name("renameCategory"), object: nil)
    }
    
    private func isSearchMode(_ searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        if !searchText.isEmpty {
            viewModel.isSearchMode = true
        }
    }
    
    func showOrHidePlaceholder() {
        let isDataEmpty = viewModel.coreDataManager.isCoreDataEmpty
        isDataEmpty ? showPlaceholderForEmptyScreen() : hidePlaceholderForEmptyScreen()
    }
    
    private func showPlaceholderForEmptyScreen() {
        if viewModel.isSearchMode {
            swooshImage.image = UIImage(named: "searchPlaceholder")
            textLabel.text = "Ничего не найдено"
        } else {
            swooshImage.image = UIImage(named: "swoosh")
            textLabel.text = "Что будем отслеживать?"
        }
        
        swooshImage.isHidden = false
        textLabel.isHidden = false
        filtersButton.isHidden = true
        
        textLabel.font = .systemFont(ofSize: 12, weight: .medium)
        textLabel.textAlignment = .center
        
        view.addSubViews([swooshImage, textLabel])
        
        NSLayoutConstraint.activate([
            swooshImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            swooshImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            textLabel.topAnchor.constraint(equalTo: swooshImage.bottomAnchor, constant: 8),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func hidePlaceholderForEmptyScreen() {
        swooshImage.isHidden = true
        textLabel.isHidden = true
        filtersButton.isHidden = false
    }
    
    func showDoneOrUndoneTaskForDatePickerDate(tracker: TrackerCoreData, cell: TrackerCollectionViewCell) {
        let trackerColor = UIColor(hex: tracker.colorHex ?? "#000000")
        let dateOnDatePicker = datePicker.date
        
        guard let check = viewModel.isTrackerExistInTrackerRecordForDatePickerDate(tracker: tracker, dateOnDatePicker: dateOnDatePicker) else { return }
        
        if !check {
            designInCompleteTracker(cell: cell, cellColor: trackerColor)
        } else {
            designCompletedTracker(cell: cell, cellColor: trackerColor)
        }
    }
    
    func makeTrackerDoneOrUndone(trackerRecord: (TrackerRecord: TrackerRecord, isExist: Bool), cellColor: UIColor, cell: TrackerCollectionViewCell) {
        if !trackerRecord.isExist {
            makeTrackerDone(trackToAdd: trackerRecord.TrackerRecord, cellColor: cellColor, cell: cell)
        } else {
            makeTrackerUndone(trackToRemove: trackerRecord.TrackerRecord, cellColor: cellColor, cell: cell)
        }
    }
    
    private func makeTrackerDone(trackToAdd: TrackerRecord, cellColor: UIColor, cell: TrackerCollectionViewCell) {
        viewModel.coreDataManager.addTrackerRecord(trackerToAdd: trackToAdd)
        
        let trackerCount = viewModel.coreDataManager.countOfTrackerInRecords(trackerIDToCount: trackToAdd.id.uuidString)
        let correctDaysInRussian = viewModel.daysLetters(count: trackerCount)
        cell.daysLabel.text = correctDaysInRussian
        
        designCompletedTracker(cell: cell, cellColor: cellColor)
        
    }
    
    private func makeTrackerUndone(trackToRemove: TrackerRecord, cellColor: UIColor, cell: TrackerCollectionViewCell) {
        
        viewModel.coreDataManager.removeTrackerRecordForThisDay(trackerToRemove: trackToRemove)
        
        let trackerCount = viewModel.coreDataManager.countOfTrackerInRecords(trackerIDToCount: trackToRemove.id.uuidString)
        let correctDaysInRussian = viewModel.daysLetters(count: trackerCount)
        cell.daysLabel.text = correctDaysInRussian
        
       designInCompleteTracker(cell: cell, cellColor: cellColor)
        
    }
    
    func designCompletedTracker(cell: TrackerCollectionViewCell, cellColor: UIColor) {
        let doneImage = UIImage(named: "done")
        cell.plusButton.setImage(doneImage, for: .normal)
        cell.plusButton.backgroundColor = cellColor.withAlphaComponent(0.3)
    }
    
    func designInCompleteTracker(cell: TrackerCollectionViewCell, cellColor: UIColor) {
        let plusImage = UIImage(systemName: "plus")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        cell.plusButton.backgroundColor = cellColor.withAlphaComponent(1)
        cell.plusButton.setImage(plusImage, for: .normal)
        cell.plusButton.layer.cornerRadius = cell.plusButton.frame.width / 2
    }
    
}
