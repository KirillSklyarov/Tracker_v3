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
    private let searchController = UISearchController(searchResultsController: nil)
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private let datePicker = UIDatePicker()
    
    private lazy var dateButton: UIButton = {
        let button = UIButton()
        let date = dateToString(date: datePicker.date)
        button.setTitle(date, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 77, height: 34)
        button.backgroundColor = UIColor(named: "textFieldBackgroundColor")
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
        return button
    } ()
    
    private lazy var filtersButton: UIButton = {
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
    private let coreDataManager = TrackerCoreManager.shared
    
    private var categories = [TrackerCategory]()
    private var filteredData = [TrackerCategory]()
    
    private var isSearchMode = false
    
    private lazy var currentDate = datePicker.date
    
    private var newData: [TrackerCategory] {
        isSearchMode ? filteredData : categories
    }
    
    private var weekDay: String {
        get {
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.weekday], from: currentDate)
            let weekDay = dateComponents.weekday
            let weekDayString = dayNumberToDayString(weekDayNumber: weekDay)
            return weekDayString
        }
    }
    
    weak var passTrackerToEditDelegate: PassTrackerToEditDelegate?
    
    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coreDataManager.setupFetchedResultsController(weekDay: weekDay)
        
        categories = coreDataManager.fetchData()
        
        coreDataManager.delegate = self
        
        setupNavigation()
        
        setupSearchController()
        
        setupCollectionView()
        
        setupFiltersButton()
        
        setupUI()
        
        setupNotification()
        
        addTapGestureToHideDatePicker()
        
    }
    
    // MARK: - UI Actions
    @objc private func addNewHabitButtonTapped(_ sender: UIButton) {
        let creatingNewHabitVC = ChoosingTypeOfHabitViewController()
        let creatingNavi = UINavigationController(rootViewController: creatingNewHabitVC)
        present(creatingNavi, animated: true)
        creatingNewHabitVC.closeScreenDelegate = self
    }
    
    @objc private func updateDataWithNewCategoryNames(notification: Notification) {
        coreDataManager.setupFetchedResultsController(weekDay: weekDay)
        collectionView.reloadData()
    }
    
    @objc private func cellButtonTapped(_ sender: UIButton) {
        let buttonIndexPath = sender.convert(CGPoint.zero, to: self.collectionView)
        
        guard let indexPath = collectionView.indexPathForItem(at: buttonIndexPath),
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else { return }
        
        let category = newData[indexPath.section]
        let tracker = category.trackers[indexPath.row]
        let currentDateString = dateToString(date: currentDate)
        
        guard let cellColor = cell.frameView.backgroundColor else { print("Color problem"); return }
        
        let trackerToOperate = TrackerRecord(id: tracker.id, date: currentDateString)
        
        let check = coreDataManager.isTrackerExistInTrackerRecord(trackerToCheck: trackerToOperate)
        
        if !check {
            makeTaskDone(trackToAdd: trackerToOperate, cellColor: cellColor, cell: cell)
        } else {
            makeTaskUndone(trackToRemove: trackerToOperate, cellColor: cellColor, cell: cell)
        }
    }
    
    @objc private func dateButtonTapped(_ sender: UIButton) {
        setupDatePicker()
    }
    
    @objc private func datePickerTapped(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        currentDate = selectedDate
        let date = dateToString(date: selectedDate)
        dateButton.setTitle(date, for: .normal)
        
        sender.removeFromSuperview()
        
        coreDataManager.setupFetchedResultsController(weekDay: weekDay)
        collectionView.reloadData()
        showOrHidePlaceholder()
        navigationItem.searchController = searchController
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
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
    
    private func setupCollectionView() {
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        
        collectionView.register(SuplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.register(SuplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
        
        view.addSubViews([collectionView])
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
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
    private func dayNumberToDayString(weekDayNumber: Int?) -> String {
        let weekDay: [Int:String] = [1: "Вс", 2: "Пн", 3: "Вт", 4: "Ср",
                                     5: "Чт", 6: "Пт", 7: "Сб"]
        guard let weekDayNumber = weekDayNumber,
              let result = weekDay[weekDayNumber] else { return ""}
        return result
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateDataWithNewCategoryNames), name: Notification.Name("renameCategory"), object: nil)
    }
    
    private func isSearchMode(_ searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        if !searchText.isEmpty {
            isSearchMode = true
        }
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        let dateToString = formatter.string(from: date)
        return dateToString
    }
    
    private func showOrHidePlaceholder() {
        let isDataEmpty = coreDataManager.isCoreDataEmpty
        isDataEmpty ? showPlaceholderForEmptyScreen() : hidePlaceholderForEmptyScreen()
    }
    
    private func showPlaceholderForEmptyScreen() {
        if isSearchMode {
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
    
    private func daysLetters(count: Int) -> String {
        if count % 10 == 1 && count % 100 != 11 {
            return "\(count) день"
        } else if [2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 10) {
            return "\(count) дня"
        } else {
            return "\(count) дней"
        }
    }
    
    private func showDoneOrUndoneTaskForDatePickerDate(tracker: TrackerCoreData, cell: TrackerCollectionViewCell) {
        let dateOnDatePicker = datePicker.date
        let dateOnDatePickerString = dateToString(date: dateOnDatePicker)
        
        let trackerColor = UIColor(hex: tracker.colorHex ?? "#000000")
        let color = trackerColor
        
        guard let trackerId = tracker.id else { return }
        let trackerToCheck = TrackerRecord(id: trackerId, date: dateOnDatePickerString)
        
        let check = coreDataManager.isTrackerExistInTrackerRecord(trackerToCheck: trackerToCheck)
        
        if !check {
            let plusImage = UIImage(systemName: "plus")?.withTintColor(.white, renderingMode: .alwaysOriginal)
            cell.plusButton.setImage(plusImage, for: .normal)
        } else {
            let doneImage = UIImage(named: "done")
            cell.plusButton.setImage(doneImage, for: .normal)
            cell.plusButton.backgroundColor = color.withAlphaComponent(0.3)
        }
    }
    
    private func makeTaskDone(trackToAdd: TrackerRecord, cellColor: UIColor, cell: TrackerCollectionViewCell) {
        coreDataManager.addTrackerRecord(trackerToAdd: trackToAdd)
        
        let trackerCount = coreDataManager.countOfTrackerInRecords(trackerIDToCount: trackToAdd.id.uuidString)
        let correctDaysInRussian = daysLetters(count: trackerCount)
        cell.daysLabel.text = correctDaysInRussian
        
        
        let doneImage = UIImage(named: "done")
        cell.plusButton.setImage(doneImage, for: .normal)
        cell.plusButton.backgroundColor = cellColor.withAlphaComponent(0.3)
        
    }
    
    private func makeTaskUndone(trackToRemove: TrackerRecord, cellColor: UIColor, cell: TrackerCollectionViewCell) {
        
        coreDataManager.removeTrackerRecordForThisDay(trackerToRemove: trackToRemove)
        
        let trackerCount = coreDataManager.countOfTrackerInRecords(trackerIDToCount: trackToRemove.id.uuidString)
        let correctDaysInRussian = daysLetters(count: trackerCount)
        cell.daysLabel.text = correctDaysInRussian
        
        let plusImage = UIImage(systemName: "plus")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        cell.plusButton.backgroundColor = cellColor.withAlphaComponent(1)
        cell.plusButton.setImage(plusImage, for: .normal)
        cell.plusButton.layer.cornerRadius = cell.plusButton.frame.width / 2
        
    }
}
// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension TrackerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        coreDataManager.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        coreDataManager.numberOfRowsInSection(section)
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
        guard let tracker = coreDataManager.object(at: indexPath),
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
        
        let trackerCount = coreDataManager.countOfTrackerInRecords(trackerIDToCount: trackerID.uuidString)
        let correctDaysInRussian = daysLetters(count: trackerCount)
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
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? SuplementaryView else {
            print("We have some problems with header"); return UICollectionReusableView()
        }
        
        if let headers = coreDataManager.fetchedResultsController?.sections  {
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

// MARK: - UISearchResultsUpdating
extension TrackerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchBarText = searchController.searchBar.text?.lowercased(),
           !searchBarText.isEmpty {
            filteredData = categories.map { category in
                let filteredTrackers = category.trackers.filter { $0.name.lowercased().contains(searchBarText) }
                return TrackerCategory(header: category.header, trackers: filteredTrackers)
            }
            filteredData = filteredData.filter({ !$0.trackers.isEmpty })
        } else {
            filteredData = categories
        }
        collectionView.reloadData()
        showOrHidePlaceholder()
    }
}

// MARK: - HideDatePicker
extension TrackerViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: view)
        return !datePicker.frame.contains(location)
    }
    
    func addTapGestureToHideDatePicker() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        
        if !datePicker.frame.contains(location) {
            datePicker.isHidden = true
        }
    }
}

// MARK: - Context Menu
extension TrackerViewController: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(actionProvider: { (_) -> UIMenu? in
            
            let lockAction = UIAction(title: "Закрепить") { _ in }
            let editAction = UIAction(title: "Редактировать") { _ in
                
                let convertedLocation = self.collectionView.convert(location, from: interaction.view)
                
                guard let indexPath = self.collectionView.indexPathForItem(at: convertedLocation) else {
                    print("We have a problem with editing a tracker"); return
                }
                
                guard let cell = self.collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell,
                      let daysCountText = cell.daysLabel.text else {
                    print("Unable to get cell for indexPath: \(indexPath)")
                    return
                }
                
                let editingVC = EditingTrackerViewController()
                self.passTrackerToEditDelegate = editingVC
                let navVC = UINavigationController(rootViewController: editingVC)
                self.present(navVC, animated: true)
                self.passTrackerToEditDelegate?.getTrackerToEditFromCoreData(indexPath: indexPath, labelText: daysCountText)
            }
            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { _ in
                self.showAlert(location: location, interaction: interaction)
            }
            
            let menu = UIMenu(children: [lockAction, editAction, deleteAction])
            
            return  menu
        }
        )
    }
    
    
    private func showAlert(location: CGPoint, interaction: UIContextMenuInteraction) {
        let alert = UIAlertController(title: "Уверены, что хотите удалить трекер", message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            let convertedLocation = self.collectionView.convert(location, from: interaction.view)
            
            guard let indexPath = self.collectionView.indexPathForItem(at: convertedLocation) else {
                print("We have a problem with deleting a tracker"); return
            }
            
            self.coreDataManager.deleteAllTrackerRecordsForTracker(at: indexPath)
            self.coreDataManager.deleteTracker(at: indexPath)
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
}

extension TrackerViewController: DataProviderDelegate {
    
    func didUpdate(_ update: TrackersStoreUpdate) {
        collectionView.reloadData()
        showOrHidePlaceholder()
    }
}

extension TrackerViewController: FilterCategoryDelegate {
    func getFilterFromPreviousVC(filter: String) {
        switch filter {
        case "Все трекеры":
            coreDataManager.setupFetchedResultsController(weekDay: weekDay)
        case "Трекеры на сегодня":
            let calendar = Calendar.current
            let date = Date()
            let dateComponents = calendar.dateComponents([.weekday], from: date)
            let weekDay = dateComponents.weekday
            let weekDayString = dayNumberToDayString(weekDayNumber: weekDay)
            print(weekDayString)
            coreDataManager.setupFetchedResultsController(weekDay: weekDayString)
            collectionView.reloadData()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yy"
            let dateToString = formatter.string(from: date)
            dateButton.setTitle(dateToString, for: .normal)
            datePicker.date = date
            
        case "Завершенные": dismiss(animated: true)
        default: dismiss(animated: true)
        }
    }
}

extension TrackerViewController: CloseScreenDelegate {
    func closeFewVCAfterCreatingTracker() {
        categories = coreDataManager.fetchData()
        self.dismiss(animated: true)
    }
}
