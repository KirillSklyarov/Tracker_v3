//
//  ChoosingCategoryVC+TableView.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 06.04.2024.
//

import UIKit

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ChoosingCategoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func setupTableView() {
        
        showPlaceholderForEmptyScreen()
        
        categoryTableView.dataSource = self
        categoryTableView.delegate = self
        categoryTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        categoryTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        categoryTableView.layer.cornerRadius = 16
//        categoryTableView.tableHeaderView = UIView()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        viewModel.rowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor(named: "textFieldBackgroundColor")
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.text = viewModel.categories[indexPath.row]
        
        let lastChosenCategory = viewModel.getLastChosenCategoryFromStore()
        
        if lastChosenCategory == cell.textLabel?.text {
            let selectionImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 14, height: 14))
            selectionImage.image = UIImage(named: "bluecheckmark")
            cell.accessoryView = selectionImage
        }
                
        if indexPath.row == 0 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        if indexPath.row == viewModel.categories.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.selectionStyle = .none
        let selectionImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 14, height: 14))
        selectionImage.image = UIImage(named: "bluecheckmark")
        cell?.accessoryView = selectionImage
        
        guard let categoryNameToPass = cell?.textLabel?.text else { return }
        
        viewModel.sendLastChosenCategoryToStore(categoryName: categoryNameToPass)
        
        updateCategory?(categoryNameToPass)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryView = UIView()
    }
}
