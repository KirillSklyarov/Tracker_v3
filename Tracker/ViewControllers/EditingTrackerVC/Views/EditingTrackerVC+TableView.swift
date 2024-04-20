//
//  EditingTrackerVC+TableView.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 11.04.2024.
//

import UIKit

// MARK: - UITableViewDataSource, UITableViewDelegate
extension EditingTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.layer.cornerRadius = 10
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tableView.separatorColor = AppColors.separatorColor
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.tableViewRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = viewModel.tableViewRows[indexPath.row]
        cell.backgroundColor = AppColors.textFieldBackground
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.detailTextLabel?.textColor = AppColors.buttonGray
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.selectionStyle = .none
        
        if indexPath.row == 0 {
            if viewModel.category != nil {
                cell.detailTextLabel?.text = viewModel.category
            }
        } else {
            if viewModel.schedule != nil {
                cell.detailTextLabel?.text = viewModel.schedule
            }
        }
        
        let disclosureImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 7, height: 12))
        disclosureImage.image = UIImage(named: "chevron")
        cell.accessoryView = disclosureImage
        
        if indexPath.row == viewModel.tableViewRows.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = viewModel.tableViewRows[indexPath.row]
        if data == SGen.category {
            let viewModel = ChoosingCategoryViewModel()
            let categoryVC = ChoosingCategoryViewController(viewModel: viewModel)
            let navVC = UINavigationController(rootViewController: categoryVC)
            categoryVC.viewModel.updateCategory = { [weak self] categoryName in
                guard let self = self,
                      let cell = tableView.cellForRow(at: indexPath) else { return }
                cell.detailTextLabel?.text = categoryName
                self.viewModel.category = categoryName
            }
            present(navVC, animated: true)
        } else {
            let scheduleVC = ScheduleViewController()
            let navVC = UINavigationController(rootViewController: scheduleVC)
            scheduleVC.viewModel.scheduleToPass = { [weak self] schedule in
                guard let self = self,
                      let cell = tableView.cellForRow(at: indexPath) else { return }
                cell.detailTextLabel?.text = schedule
                self.viewModel.schedule = schedule
            }
            present(navVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
