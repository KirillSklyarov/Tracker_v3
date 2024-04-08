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
                                
        categoryTableView.dataSource = self
        categoryTableView.delegate = self
        categoryTableView.register(CustomCategoryCell.self, forCellReuseIdentifier: CustomCategoryCell.identifier)
        
        categoryTableView.layer.cornerRadius = 16
        categoryTableView.tableHeaderView = UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        viewModel.rowHeight
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
        
        viewModel.showLastChosenCategory(cell: cell)
        
        designFirstAndLastCell(indexPath: indexPath, cell: cell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CustomCategoryCell else { return }
        viewModel.choosingCategory(cell: cell)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CustomCategoryCell else { return }
        viewModel.deSelectCell(cell: cell)
    }
}
