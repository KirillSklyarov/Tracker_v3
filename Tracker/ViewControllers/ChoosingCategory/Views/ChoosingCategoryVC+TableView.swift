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
        
        categoryTableView.layer.cornerRadius = 16
        categoryTableView.tableHeaderView = UIView()
        categoryTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        categoryTableView.dataSource = self
        categoryTableView.delegate = self
        categoryTableView.register(CustomCategoryCell.self, forCellReuseIdentifier: CustomCategoryCell.identifier)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        rowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomCategoryCell.identifier, for: indexPath) as? CustomCategoryCell else { print("We have problems with cell")
            return UITableViewCell()
        }
        let cellViewModel = viewModel.categories[indexPath.row]
        cell.configureCell(viewModelCategories: cellViewModel)
        
        showLastChosenCategory(cell: cell)
        
        designFirstAndLastCell(indexPath: indexPath, cell: cell)
        
        return cell
    }
    
    func showLastChosenCategory(cell: CustomCategoryCell) {
        let lastChosenCategory = viewModel.getLastChosenCategoryFromStore()
        if lastChosenCategory == cell.titleLabel.text {
            cell.selectionStyle = .none
            cell.checkmarkImage.isHidden = false
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CustomCategoryCell else { return }
        
        cell.selectionStyle = .none
        cell.checkmarkImage.isHidden = false
        
        sendLastChosenCategoryToStore(cell: cell)
        
        dismiss(animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CustomCategoryCell else { return }
        cell.checkmarkImage.isHidden = true
    }
    
    func sendLastChosenCategoryToStore(cell: CustomCategoryCell) {
        guard let categoryNameToPass = cell.titleLabel.text else {
            print("Oooops"); return }
        viewModel.sendLastChosenCategoryToStore(categoryName: categoryNameToPass)
        viewModel.updateCategory?(categoryNameToPass)
    }
}
