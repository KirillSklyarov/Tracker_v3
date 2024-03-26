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
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    } ()
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton()
        button.setTitle("Фильтры", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "filterButtonBackground")
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
        return button
    } ()
    
    // MARK: - Private Properties
    
    private var categoryNames: [String] {
        newData.map { $0.header }
    }
    
    let categoryStorage = CategoryStorage.shared
    
    var categories: [TrackerCategory] {
        if let dataBase = categoryStorage.getDataBaseFromStorage() {
            return  dataBase
        } else {
            print("Ooops we have a problem")
            return []
        }
    }
    
    var categoryNamesDelegate: PassCategoryNamesFromMainVC?
    
    private var completedTrackers: [TrackerRecord]?
    
    private var isDoneForToday = false
    private var filteredData: [TrackerCategory] = []
    private var isSearchMode = false
    
    private lazy var currentDate = datePicker.date
    
    private var newDateCategories: [TrackerCategory]?
    
    private var newData: [TrackerCategory] {
        if let newDateCategories = newDateCategories {
            newDateCategories
        } else {
            isSearchMode ? filteredData : categories
        }
    }
    
    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        completedTrackers = []
        
        setupNavigation()
        
        setupSearchController()
        
        setupCollectionView()
        
        setupFiltersButton()
        
        setupUI()
        
        passCategoryNamesToSingleton()
        
        addTapGestureToHideDatePicker()
                
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        let dateToString = formatter.string(from: currentDate)
        return dateToString
    }
    
    private func passCategoryNamesToSingleton() {
        CategoryStorage.shared.addToCategoryNamesStorage(categoryNames: categoryNames)
    }
    
    // MARK: - UI Actions
    @objc private func addNewHabit(_ sender: UIButton) {
        let creatingNewHabitVC = ChoosingTypeOfHabitViewController()
        let creatingNavi = UINavigationController(rootViewController: creatingNewHabitVC)
        present(creatingNavi, animated: true)
    }
    
    @objc private func cellButtonTapped(_ sender: UIButton) {
        let buttonIndexPath = sender.convert(CGPoint.zero, to: self.collectionView)
        
        guard let indexPath = collectionView.indexPathForItem(at: buttonIndexPath),
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else { return }
        
        let category = newData[indexPath.section]
        let tracker = category.trackers[indexPath.row]
        let currentDateString = dateToString(date: self.currentDate)
        
        guard let cellColor = cell.frameView.backgroundColor else { print("Color problem"); return }
        
        let trackForAdd = TrackerRecord(id: tracker.id, date: currentDateString)
        
        guard let check = completedTrackers?.contains(where: { $0.id == trackForAdd.id && $0.date == trackForAdd.date}) else { return }
        if !check {
            makeTaskDone(trackForAdd: trackForAdd, cellColor: cellColor, cell: cell)
        } else {
            makeTaskUndone(trackForAdd: trackForAdd, cellColor: cellColor, cell: cell)
        }
    }
    
    @objc private func dateButtonTapped(_ sender: UIButton) {
        setupDatePicker()
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
    
    @objc private func datePickerTapped(_ sender: UIDatePicker) {
        print("datePickerTapped")
        newDateCategories = nil
        
        let selectedDate = sender.date
        currentDate = selectedDate
        let date = dateToString(date: selectedDate)
        dateButton.setTitle(date, for: .normal)
        
        sender.removeFromSuperview()
        
        let calendar = Calendar.current
        
        let dateComponents = calendar.dateComponents([.weekday], from: currentDate)
        let weekDay = dateComponents.weekday
        let weekDayString = dayNumberToDayString(weekDayNumber: weekDay)
        
        newDateCategories = filterNewDataFromData(weekDay: weekDayString)
        collectionView.reloadData()
        showOrHidePlaceholder()
        navigationItem.searchController = searchController
    }
    
    @objc private func filterButtonTapped(_ sender: UIButton) {
        
    }
    
    
    // MARK: - UI, Navigation, Search
    private func setupNavigation() {
        
        navigationItem.hidesSearchBarWhenScrolling = false
        
        let image = UIImage(systemName: "plus")?.withRenderingMode(.alwaysOriginal)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dateButton)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image?.withTintColor(.black), style: .done, target: self, action: #selector(addNewHabit))
    }
    
    private func dayNumberToDayString(weekDayNumber: Int?) -> String {
        let weekDay: [Int:String] = [1: "Вс", 2: "Пн", 3: "Вт", 4: "Ср",
                                     5: "Чт", 6: "Пт", 7: "Сб"]
        guard let weekDayNumber = weekDayNumber,
              let result = weekDay[weekDayNumber] else { return ""}
        return result
    }
    
    private func filterNewDataFromData(weekDay: String) -> [TrackerCategory] {
        var result: [TrackerCategory] = []
        var element: [Tracker] = []
        
        for category in newData {
            for i in category.trackers {
                if i.schedule.contains(weekDay) {
                    element.append(i)
                }
            }
            if !element.isEmpty {
                result.append(TrackerCategory(header: category.header, trackers: element))
                element = []
            }
        }
        return result
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
    
    // MARK: - Private Methods
    private func isSearchMode(_ searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        if !searchText.isEmpty {
            isSearchMode = true
        }
    }
    
    private func showOrHidePlaceholder() {
        newData.isEmpty ? showPlaceholderForEmptyScreen() : hidePlaceholderForEmptyScreen()
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
    }
    
}
// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension TrackerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        categoryNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newData[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as? TrackerCollectionViewCell else { print("We have some problems with CustomCell");
            return UICollectionViewCell()
        }
        
        let iteraction = UIContextMenuInteraction(delegate: self)
        cell.frameView.addInteraction(iteraction)
        
        configureCell(cell: cell, indexPath: indexPath)
        
        return cell
    }
    
    private func configureCell(cell: TrackerCollectionViewCell, indexPath: IndexPath) {
        let categories = newData[indexPath.section]
        let trackersInCategory = categories.trackers
        let tracker = trackersInCategory[indexPath.row]
        let frameColor = tracker.color
        let today = Date()
                
        cell.titleLabel.text = tracker.name
        cell.emojiLabel.text = tracker.emoji
        
        cell.frameView.backgroundColor = frameColor
        cell.plusButton.backgroundColor = frameColor
        
        cell.plusButton.addTarget(self, action: #selector(cellButtonTapped), for: .touchUpInside)
        cell.plusButton.isEnabled = currentDate > today ? false : true
        
        showDoneOrUndoneTaskForDatePickerDate(tracker: tracker, cell: cell)
        
    }
    
    private func showDoneOrUndoneTaskForDatePickerDate(tracker: Tracker, cell: TrackerCollectionViewCell) {
        let dateOnDatePicker = datePicker.date
        let dateOnDatePickerString = dateToString(date: dateOnDatePicker)
        let color = tracker.color
        
        guard let check = completedTrackers?.contains(where: { $0.id == tracker.id && $0.date == dateOnDatePickerString }) else { return }
        
        if !check {
//            print("Нет в списке - значит ставим плюсик")
            let plusImage = UIImage(systemName: "plus")?.withTintColor(.white, renderingMode: .alwaysOriginal)
            cell.plusButton.setImage(plusImage, for: .normal)
        } else {
//            print("Хм - есть в списке, значит галку ставим")
            let doneImage = UIImage(named: "done")
            cell.plusButton.setImage(doneImage, for: .normal)
            cell.plusButton.backgroundColor = color.withAlphaComponent(0.3)
        }
    }
    
    
    private func makeTaskDone(trackForAdd: TrackerRecord, cellColor: UIColor, cell: TrackerCollectionViewCell) {
        completedTrackers?.append(trackForAdd)
        let doneImage = UIImage(named: "done")
        cell.plusButton.setImage(doneImage, for: .normal)
        cell.plusButton.backgroundColor = cellColor.withAlphaComponent(0.3)
        cell.days += 1
        cell.daysLabel.text = "\(cell.days) день"
        print(completedTrackers!)
    }
    
    private func makeTaskUndone(trackForAdd: TrackerRecord, cellColor: UIColor, cell: TrackerCollectionViewCell) {
        let plusImage = UIImage(systemName: "plus")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        cell.plusButton.backgroundColor = cellColor.withAlphaComponent(1)
        cell.plusButton.setImage(plusImage, for: .normal)
        cell.plusButton.layer.cornerRadius = cell.plusButton.frame.width / 2
        
        cell.days -= 1
        cell.daysLabel.text = "\(cell.days) день"
        if let index = completedTrackers?.firstIndex(where: { $0.id == trackForAdd.id && $0.date == trackForAdd.date}) {
            completedTrackers?.remove(at: index)
        }
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
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! SuplementaryView
        view.label.text = newData[indexPath.section].header
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell
        cell?.titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell
        cell?.titleLabel.font = .systemFont(ofSize: 17, weight: .regular)
    }
}

// MARK: - UICollectionViewDelegateFlowLayou
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
            let editAction = UIAction(title: "Редактировать") { _ in }
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { _ in }
            
            return UIMenu(children: [lockAction, editAction, deleteAction]) }
        )
    }
                                          

   
//    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
//        let touchPoint = interaction.view?.convert(location, from: self)
//    }
    
    
    
//    
//    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
//        guard indexPaths.count > 0 else { return nil }
//        let indexPath = indexPaths[0]
//        return UIContextMenuConfiguration(actionProvider: { _ in return self.showContextMenu(indexPath: indexPath) }
//        )
//    }
    
    func showContextMenu(indexPath: IndexPath) -> UIMenu {
        let lockAction = UIAction(title: "Закрепить") { _ in }
        let editAction = UIAction(title: "Редактировать") { _ in }
        let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { _ in }
    
        return UIMenu(children: [lockAction, editAction, deleteAction])
    }
}
    
    
//    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
//        return UIContextMenuConfiguration(actionProvider:
//                { _ in return self.showContextMenu(indexPath: indexPath) }
//        )
//    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let interaction = UIContextMenuInteraction(delegate: self)
//        cell.addInteraction(interaction)
//    }
    
//    private func designLastCell(indexPath: IndexPath) {
//        let indexPathOfLastCell = IndexPath(row: self.categories.count - 1, section: indexPath.section)
//        guard let cell = self.categoryTableView.cellForRow(at: indexPathOfLastCell) else { return }
//            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
//            cell.layer.cornerRadius = 16
//            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
//    }
//}


//MARK: - SwiftUI
import SwiftUI
struct Provider01 : PreviewProvider {
    static var previews: some View {
        ContainterView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainterView: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> UIViewController {
            return TrackerViewController()
        }
        
        typealias UIViewControllerType = UIViewController
        
        let viewController = TrackerViewController()
        func makeUIViewController(context: UIViewControllerRepresentableContext<Provider01.ContainterView>) -> TrackerViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: Provider01.ContainterView.UIViewControllerType, context: UIViewControllerRepresentableContext<Provider01.ContainterView>) {
            
        }
    }
}
