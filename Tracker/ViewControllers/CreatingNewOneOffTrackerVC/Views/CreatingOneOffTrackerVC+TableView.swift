//
//  CreatingOneOffTrackerVC+TableView.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 08.04.2024.
//

import UIKit

// MARK: -  UITableViewDataSource, UITableViewDelegate
extension CreatingOneOffTrackerVC: UITableViewDataSource, UITableViewDelegate {
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.layer.cornerRadius = 10
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.tableViewRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = viewModel.tableViewRows[indexPath.row]
        cell.backgroundColor = UIColor(named: "textFieldBackgroundColor")
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.detailTextLabel?.textColor = UIColor(named: "createButtonGrayColor")
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.selectionStyle = .none
        
        let disclosureImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 7, height: 12))
        disclosureImage.image = UIImage(named: "chevron")
        cell.accessoryView = disclosureImage
        
        // Убираем сепаратор у последней ячейки
        if indexPath.row == viewModel.tableViewRows.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = ChoosingCategoryViewModel()
        let categoryVC = ChoosingCategoryViewController(viewModel: viewModel)
        let navVC = UINavigationController(rootViewController: categoryVC)
        categoryVC.viewModel.updateCategory = { [weak self] categoryName in
            guard let self = self,
                  let cell = tableView.cellForRow(at: indexPath) else { return }
            cell.detailTextLabel?.text = categoryName
            self.viewModel.selectedCategory = categoryName
        }
        present(navVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

