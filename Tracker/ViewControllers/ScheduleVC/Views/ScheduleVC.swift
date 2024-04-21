//
//  ScheduleVC.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 14.03.2024.
//

import UIKit

final class ScheduleViewController: UIViewController {
    
    // MARK: - UI Properties
    let tableView = UITableView()
    let doneButton = UIButton()
    
    // MARK: - Public Properties
    let viewModel = ScheduleViewModel()
            
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
    }
    
    // MARK: - IB Actions
    @objc func weekDaySwitchValueChanged(_ sender: UISwitch) {
        guard let cell = sender.superview as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else { return }
        let sender = sender.isOn
        viewModel.appendOrRemoveArray(sender: sender, indexPath: indexPath)
    }
    
    @objc private func scheduleDoneButtonTapped(_ sender: UIButton) {
        viewModel.passScheduleToCreatingTrackerVC()
        dismiss(animated: true)
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        
        setupButton()
        
        setupTableView()
                
        self.title = SGen.schedule
        view.backgroundColor = AppColors.background
        
        view.addSubViews([tableView, doneButton])
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: viewModel.tableViewHeight),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
    
    private func setupButton() {
        doneButton.setTitle(SGen.done, for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        doneButton.setTitleColor(AppColors.buttonText, for: .normal)
        doneButton.backgroundColor = AppColors.buttonBlack
        doneButton.layer.masksToBounds = true
        doneButton.layer.cornerRadius = 15
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        doneButton.addTarget(self, action: #selector(scheduleDoneButtonTapped), for: .touchUpInside)
    }
}
