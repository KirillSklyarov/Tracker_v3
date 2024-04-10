//
//  ChoosingCategoryVC+ContextMenu.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 06.04.2024.
//

import UIKit

// MARK: - Context Menu
extension ChoosingCategoryViewController: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(
            actionProvider:
                { _ in return self.showContextMenu(indexPath: indexPath) }
        )
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let interaction = UIContextMenuInteraction(delegate: self)
        cell.addInteraction(interaction)
    }
    
    private func showContextMenu(indexPath: IndexPath) -> UIMenu {
        let editAction = UIAction(title: "Редактировать") { [weak self] _ in
            guard let self = self,
                  let cell = self.categoryTableView.cellForRow(at: indexPath) as? CustomCategoryCell else { return }
            openEditingCategoryVC(cell: cell)
        }
        
        let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { _ in
            self.showAlert(indexPath: indexPath)
        }
        return UIMenu(children: [editAction, deleteAction])
    }
    
    private func openEditingCategoryVC(cell: CustomCategoryCell) {
        guard let categoryNameToPass = cell.titleLabel.text else { print("We have some problems here"); return }
        let editingVC = EditingCategoryViewController()
        let navVC = UINavigationController(rootViewController: editingVC)
        self.viewModel.delegateToPassCategoryNameToEdit = editingVC
        viewModel.delegateToPassCategoryNameToEdit?.getCategoryNameFromPreviousVC(categoryName: categoryNameToPass)
        
        editingVC.viewModel.updateCategoryNameClosure = { [weak self] in
            guard let self else { return }
            self.viewModel.getDataFromCoreData()
        }
        
        present(navVC, animated: true)
    }
    
    
    private func showAlert(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Эта категория точно не нужна", message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self,
                  let cell = self.categoryTableView.cellForRow(at: indexPath) as? CustomCategoryCell else { return }
            deleteCategory(cell: cell, indexPath: indexPath)
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        
        [deleteAction, cancelAction].forEach({ alert.addAction($0)})
        
        self.present(alert, animated: true)
    }
    
    private func deleteCategory(cell: CustomCategoryCell, indexPath: IndexPath) {
        guard let categoryNameToDelete = cell.titleLabel.text else { return }
        viewModel.deleteCategory(categoryNameToDelete: categoryNameToDelete)
    }
    
    func designFirstAndLastCell(indexPath: IndexPath, cell: UITableViewCell) {
        
        if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        
        if indexPath.row == viewModel.categories.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
    }
}
