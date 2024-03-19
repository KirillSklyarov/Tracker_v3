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
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        let dateToString = formatter.string(from: currentDate)
        button.setTitle(dateToString, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 77, height: 34)
        button.backgroundColor = UIColor(named: "textFieldBackgroundColor")
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(datePickerTapped), for: .touchUpInside)
        return button
    } ()
    
    
    // MARK: - Private Properties
    var categories: [TrackerCategory] = [
        TrackerCategory(header: "Домашний уют", trackers:
                            [Tracker(id: UUID(), name: "Поливать цветы", color: UIColor.systemBrown, emoji: "\u{1F929}", schedule: "0")])
    ]
    
    private var categoryNames: [String] {
            categories.map { $0.header }
        }
    
    var categoryNamesDelegate: passCategoryNamesFromMainVC?
    
    private var completedTrackers: [TrackerRecord]?
    
    private var isDoneForToday = false
    private var filteredData: [TrackerCategory] = []
    private var isSearchMode = false
    private var currentDate = UIDatePicker().date
    
    private var newData: [TrackerCategory] {
        isSearchMode ? filteredData : categories
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
        
        
//        let chooseCategoryVC = ChoosingCategoryViewController()
//        self.categoryNamesDelegate = chooseCategoryVC
//        categoryNamesDelegate?.passCategoryNames(categoryNames: categoryNames)
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
    
    @objc private func plusButtonTapped(_ sender: UIButton) {
        let buttonIndexPath = sender.convert(CGPoint.zero, to: self.collectionView)
        
        guard let indexPath = collectionView.indexPathForItem(at: buttonIndexPath),
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else { return }
        
        let category = newData[indexPath.section]
                
        let tracker = category.trackers[indexPath.row]
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        let currentDate = formatter.string(from: Date())
        guard let cellColor = cell.frameView.backgroundColor else { print("Color probler"); return }
        
        let trackForAdd = TrackerRecord(id: tracker.id, date: currentDate)
        
        guard let check = completedTrackers?.contains(where: { $0.id == trackForAdd.id && $0.date == trackForAdd.date}) else { return }
        if !check {
            makeTaskDone(trackForAdd: trackForAdd, cellColor: cellColor, cell: cell)
        } else {
            makeTaskUndone(trackForAdd: trackForAdd, cellColor: cellColor, cell: cell)
        }
    }
    
    // MARK: - UI, Navigation, Search
    private func setupNavigation() {
        
        navigationItem.hidesSearchBarWhenScrolling = false
                
        let image = UIImage(systemName: "plus")?.withRenderingMode(.alwaysOriginal)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePickerButton)
            
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image?.withTintColor(.black), style: .done, target: self, action: #selector(addNewHabit))
    }
    
    @objc private func datePickerTapped(_ sender: UIButton) {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.layer.backgroundColor = UIColor.white.cgColor
        picker.layer.cornerRadius = 13
        if #available(iOS 14.0, *) {
            picker.preferredDatePickerStyle = .inline
        } else {
            picker.preferredDatePickerStyle = .wheels
        }
        picker.addTarget(self, action: #selector(datePickerTapped2), for: .valueChanged)
        
        navigationItem.searchController = nil
       
        view.addSubViews([picker])

        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            picker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            picker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            picker.heightAnchor.constraint(greaterThanOrEqualToConstant: 325)
        ])
    }
    
    @objc private func datePickerTapped2(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        currentDate = selectedDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        datePickerButton.setTitle(formattedDate, for: .normal)
        sender.removeFromSuperview()
        navigationItem.searchController = searchController
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
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
        isSearchMode(searchController)

        return newData.count
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
        let category = newData[indexPath.section]
                
        let tracker = category.trackers[indexPath.row]
        cell.titleLabel.text = tracker.name
        let frameColor = tracker.color
        cell.frameView.backgroundColor = frameColor
        cell.emojiLabel.text = tracker.emoji
        let newButtonColor = cell.plusButton.currentImage?.withTintColor(frameColor)
        cell.plusButton.setImage(newButtonColor, for: .normal)
        cell.plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }
        
    private func makeTaskDone(trackForAdd: TrackerRecord, cellColor: UIColor, cell: TrackerCollectionViewCell) {
        completedTrackers?.append(trackForAdd)
        let config = UIImage.SymbolConfiguration(pointSize: 34)
        let doneImage = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)?.withTintColor(cellColor, renderingMode: .alwaysOriginal)
        cell.plusButton.setImage(doneImage, for: .normal)
        cell.days += 1
        cell.daysLabel.text = "\(cell.days) день"
    }
    
    private func makeTaskUndone(trackForAdd: TrackerRecord, cellColor: UIColor, cell: TrackerCollectionViewCell) {
        let plusButtonImage = UIImage(named: "plusButton")?.withTintColor(cellColor)
        cell.plusButton.setImage(plusButtonImage, for: .normal)
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
        return CGSize(width: collectionView.bounds.width / 2 - 9, height: 148)
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
        print(categories)
    }
}
