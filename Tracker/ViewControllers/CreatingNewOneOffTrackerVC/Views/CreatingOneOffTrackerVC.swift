//
//  CreatingOneOffTrackerVC.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 13.03.2024.
//

import UIKit

final class CreatingOneOffTrackerVC: UIViewController {
    
    // MARK: - UI Properties
    let trackerNameTextField = UITextField()
    let tableView = UITableView()
    let exceedLabel = UILabel()
    let emojiCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let colorsCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    lazy var cancelButton = setupButtons(title: "Отмена")
    lazy var createButton = setupButtons(title: "Создать")
    
    let screenScrollView = UIScrollView()
    let contentStackView = UIStackView()
    
    // MARK: - Private Properties
    let viewModel = CreatingOneOffTrackerViewModel()
        
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        isCreateButtonEnable()
        
        addTapGestureToHideKeyboard()
    }
    
    // MARK: - IB Actions
    @objc func clearTextButtonTapped(_ sender: UIButton) {
        trackerNameTextField.text = ""
        isCreateButtonEnable()
    }
    
    @objc func cancelButtonTapped(_ sender: UIButton) {
        viewModel.informAnotherVCofCreatingTracker?()
    }
    
    @objc func createButtonTapped(_ sender: UIButton) {
        guard let trackerName = trackerNameTextField.text else {
            print("We have a problem here")
            return
        }
        viewModel.createNewTracker(trackerNameTextField: trackerName)
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        
        setupTextField()
        
        setupTableView()
        
        setupEmojiCollectionView()
        
        setupColorsCollectionView()
        
        setupScrollView()
        
        self.title = "Новое нерегулярное событие"
        view.backgroundColor = UIColor(named: "projectBackground")
    }
        
    private func setupButtons(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }
    
    // MARK: - Public Methods
    func isCreateButtonEnable() {
        isAllFieldsFilled() ? createButtonIsActive() : createButtonIsNotActive()
    }
    
    func isAllFieldsFilled() -> Bool {
        let textFieldTest = trackerNameTextField.hasText
        return viewModel.isAllFieldsFilled(trackerNameTextField: textFieldTest)
    }
    
    func createButtonIsActive() {
        createButton.isEnabled = true
        createButton.backgroundColor = .black
    }
    
    func createButtonIsNotActive() {
        createButton.isEnabled = false
        createButton.backgroundColor = UIColor(named: "createButtonGrayColor")
    }
    
    func showLabelExceedTextFieldLimit() {
        exceedLabel.isHidden = false
        exceedLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
    }
    
    func hideLabelExceedTextFieldLimit() {
        exceedLabel.isHidden = true
    }
}
