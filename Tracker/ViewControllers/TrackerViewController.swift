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
    
    private lazy var datePickerButton: UIButton = {
        let button = UIButton()
        let date = dateToString(date: currentDate)
        button.setTitle(date, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 77, height: 34)
        button.backgroundColor = UIColor(named: "textFieldBackgroundColor")
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
        return button
    } ()
    
    
    // MARK: - Private Properties
    var categories: [TrackerCategory] = []
    
    private var categoryNames: [String] {
        newData.map { $0.header }
        }
    
    var categoryNamesDelegate: passCategoryNamesFromMainVC?
    
    private var completedTrackers: [TrackerRecord]?
    
    private var isDoneForToday = false
    private var filteredData: [TrackerCategory] = []
    private var isSearchMode = false
   
    private var currentDate = UIDatePicker().date
    
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
        
        setupUI()
        
        passCategoryNamesToSingleton()
                
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        let dateToString = formatter.string(from: currentDate)
        return dateToString
    }
    
    private func passCategoryNamesToSingleton() {
        Singeton.shared.getCategoryNames(categoryNames: categoryNames)
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
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.layer.backgroundColor = UIColor.white.cgColor
        picker.layer.cornerRadius = 13
        if #available(iOS 14.0, *) {
            picker.preferredDatePickerStyle = .inline
        } else {
            picker.preferredDatePickerStyle = .wheels
        }
        picker.addTarget(self, action: #selector(datePickerTapped), for: .valueChanged)
        
        navigationItem.searchController = nil
       
        view.addSubViews([picker])

        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            picker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            picker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            picker.heightAnchor.constraint(greaterThanOrEqualToConstant: 325)
        ])
    }
    
    @objc private func datePickerTapped(_ sender: UIDatePicker) {
        newDateCategories = nil
        
        let selectedDate = sender.date
        currentDate = selectedDate
        let date = dateToString(date: selectedDate)
        datePickerButton.setTitle(date, for: .normal)

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

    // MARK: - UI, Navigation, Search
    private func setupNavigation() {
        
        navigationItem.hidesSearchBarWhenScrolling = false
            
        let image = UIImage(systemName: "plus")?.withRenderingMode(.alwaysOriginal)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePickerButton)
            
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
        
        configureCell(cell: cell, indexPath: indexPath)
        
        return cell
    }
    
    private func configureCell(cell: TrackerCollectionViewCell, indexPath: IndexPath) {
        let categories = newData[indexPath.section]
        let trackersInCategory = categories.trackers
        let tracker = trackersInCategory[indexPath.row]
        
        cell.titleLabel.text = tracker.name
        let frameColor = tracker.color
        cell.frameView.backgroundColor = frameColor
        cell.emojiLabel.text = tracker.emoji
        let newButtonColor = cell.plusButton.currentImage?.withTintColor(frameColor)
        cell.plusButton.setImage(newButtonColor, for: .normal)
        cell.plusButton.addTarget(self, action: #selector(cellButtonTapped), for: .touchUpInside)
        
        let today = Date()
        cell.plusButton.isEnabled = currentDate > today ? false : true
    }
        
    private func makeTaskDone(trackForAdd: TrackerRecord, cellColor: UIColor, cell: TrackerCollectionViewCell) {
        completedTrackers?.append(trackForAdd)
        let doneImage = UIImage(named: "done")
        cell.plusButton.clipsToBounds = true
        cell.plusButton.layer.cornerRadius = cell.plusButton.frame.width / 2
        cell.plusButton.backgroundColor = cellColor.withAlphaComponent(0.3)
        cell.plusButton.setImage(doneImage, for: .normal)
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

extension TrackerViewController: newTaskDelegate {
    func getNewTaskFromAnotherVC(newTask: TrackerCategory) {
                categories.append(newTask)
    }
}

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
