//
//  ViewController.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 12.03.2024.
//

import UIKit

final class TrackerViewController: UIViewController {
    
    // MARK: - UI Properties
    lazy var filtersButton: UIButton = {
        let button = UIButton()
        button.setTitle(SGen.filters, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(AppColors.filterButtonTextColor, for: .normal)
        button.backgroundColor = AppColors.filterButton
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    } ()
    private let swooshImage = UIImageView()
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        return label
    } ()
    
    lazy var datePicker: UIDatePicker = {
        let myDatePicker = UIDatePicker()
        myDatePicker.datePickerMode = .date
        myDatePicker.layer.cornerRadius = 13
        if #available(iOS 14.0, *) {
            myDatePicker.preferredDatePickerStyle = .inline
        } else {
            myDatePicker.preferredDatePickerStyle = .wheels
        }
        myDatePicker.addTarget(self, action: #selector(datePickerTapped), for: .valueChanged)
        return myDatePicker
    } ()
    lazy var dateButton: UIButton = {
        let button = UIButton()
        let date = MainHelper.dateToString(date: datePicker.date)
        button.setTitle(date, for: .normal)
        button.setTitleColor(AppColors.background, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 77, height: 34)
        button.backgroundColor = AppColors.dateLabelBackground
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
        return button
    } ()
    
    let searchController = UISearchController(searchResultsController: nil)
    let trackersCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let stickyCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    // MARK: - Other Properties
    var viewModel: TrackerViewModelProtocol
    
    lazy var currentDate = datePicker.date
    
    var weekDay: String {
        viewModel.getWeekdayFromCurrentDate(currentDate: currentDate)
    }
    
    // MARK: - Initializers
    init(viewModel: TrackerViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
                
        uploadDataFormCoreData()
        
        dataBinding()
        
        setupUI()
        
        setupNotification()
        
        addTapGestureToHideDatePicker()
        
        viewModel.coreDataManager.printAllCategoryNamesFromCD()
                
    }
    
    // MARK: - UI Actions
    @objc private func addNewHabitButtonTapped(_ sender: UIButton) {
        let creatingNewHabitVC = ChoosingTypeOfTrackerViewController()
        let creatingNavi = UINavigationController(rootViewController: creatingNewHabitVC)
        present(creatingNavi, animated: true)
    }
    
    @objc private func updateDataWithNewCategoryNames(notification: Notification) {
        uploadDataFormCoreData()
    }
    
    @objc func cellButtonTapped(_ sender: UIButton) {
        let buttonIndexPath = sender.convert(CGPoint.zero, to: self.trackersCollectionView)
        
        guard let indexPath = trackersCollectionView.indexPathForItem(at: buttonIndexPath),
              let cell = trackersCollectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell,
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
        let date = MainHelper.dateToString(date: selectedDate)
        dateButton.setTitle(date, for: .normal)
        
        sender.removeFromSuperview()
        
        viewModel.updateDataFromCoreData(weekDay: weekDay)
    }
    
    @objc private func filterButtonTapped(_ sender: UIButton) {
        let viewModel = FilterViewModel()
        let filterVC = FilterTrackersViewController(viewModel: viewModel)
        let navVC = UINavigationController(rootViewController: filterVC)
        filterVC.filterDelegate = self
        present(navVC, animated: true)
    }
    
    // MARK: - UI, Navigation, Search
    private func setupNavigation() {
        
        navigationItem.hidesSearchBarWhenScrolling = false
        
        guard let color = AppColors.buttonBlack,
              let image = UIImage(systemName: "plus")?.withRenderingMode(.alwaysOriginal).withTintColor(color) else { print("We have some color problems"); return }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dateButton)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(addNewHabitButtonTapped))
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
        
        setupStickyCollectionView()
        
        setupCollectionView()
        
        setupFiltersButton()
        
        view.backgroundColor = AppColors.background
        
        showOrHidePlaceholder()
    }
    
    private func setupDatePicker() {
        datePicker.isHidden = false
        
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
    private func dataBinding() {
        viewModel.dataUpdated = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                print(self.viewModel.categories)
                self.trackersCollectionView.reloadData()
                self.showOrHidePlaceholder()
                self.navigationItem.searchController = self.searchController
            }
        }
    }
    
    private func uploadDataFormCoreData() {
        viewModel.updateDataFromCoreData(weekDay: weekDay)
        viewModel.coreDataManager.delegate = self
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateDataWithNewCategoryNames),
                                               name: Notification.Name("renameCategory"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(closeFewVCAfterCreatingTracker),
                                               name: Notification.Name("cancelCreatingTracker"),
                                               object: nil)
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
    
    func showPlaceholderForEmptyScreen() {
        if viewModel.isSearchMode {
            swooshImage.image = UIImage(named: "searchPlaceholder")
            textLabel.text = "Ничего не найдено"
        } else {
            swooshImage.image = UIImage(named: "swoosh")
            textLabel.text = "Что будем отслеживать?"
        }
        
        swooshImage.isHidden = false
        textLabel.isHidden = false
        
        if viewModel.coreDataManager.filterButtonForEmptyScreenIsEnable {
            filtersButton.isHidden = false
        } else {
            filtersButton.isHidden = true
        }
        
        view.addSubViews([swooshImage, textLabel])
        
        NSLayoutConstraint.activate([
            swooshImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            swooshImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            textLabel.topAnchor.constraint(equalTo: swooshImage.bottomAnchor, constant: 8),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    func hidePlaceholderForEmptyScreen() {
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
        
        let countOfDays = MainHelper.countOfDaysForTheTrackerInString(trackerId: trackToAdd.id.uuidString)
        cell.daysLabel.text = countOfDays
        
        designCompletedTracker(cell: cell, cellColor: cellColor)
    }
    
    private func makeTrackerUndone(trackToRemove: TrackerRecord, cellColor: UIColor, cell: TrackerCollectionViewCell) {
        viewModel.coreDataManager.removeTrackerRecordForThisDay(trackerToRemove: trackToRemove)
        
        let countOfDays = MainHelper.countOfDaysForTheTrackerInString(trackerId: trackToRemove.id.uuidString)
        cell.daysLabel.text = countOfDays
        
        designInCompleteTracker(cell: cell, cellColor: cellColor)
    }
    
    func designCompletedTracker(cell: TrackerCollectionViewCell, cellColor: UIColor) {
        guard let color = AppColors.trackerCellDoneLabel,
              let image = UIImage(named: "done") else { return }
        
        let doneImage = image.withTintColor(color)
        cell.plusButton.setImage(doneImage, for: .normal)
        cell.plusButton.backgroundColor = cellColor.withAlphaComponent(0.3)
    }
    
    func designInCompleteTracker(cell: TrackerCollectionViewCell, cellColor: UIColor) {
        guard let color = AppColors.plusButtonColor else { return }
        let plusImage = UIImage(systemName: "plus")?.withTintColor(color, renderingMode: .alwaysOriginal)
        cell.plusButton.backgroundColor = cellColor.withAlphaComponent(1)
        cell.plusButton.setImage(plusImage, for: .normal)
        cell.plusButton.layer.cornerRadius = cell.plusButton.frame.width / 2
    }
}
