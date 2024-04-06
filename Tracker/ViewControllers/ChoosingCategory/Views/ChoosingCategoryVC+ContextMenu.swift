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
    
    func showContextMenu(indexPath: IndexPath) -> UIMenu {
        let editAction = UIAction(title: "Редактировать") { [weak self] _ in
            guard let self = self,
                  let cell = self.categoryTableView.cellForRow(at: indexPath),
                  let categoryNameToPass = cell.textLabel?.text else { return }
            let editingVC = EditingCategoryViewController()
            let navVC = UINavigationController(rootViewController: editingVC)
            self.viewModel.delegateToPassCategoryNameToEdit = editingVC
            viewModel.delegateToPassCategoryNameToEdit?.getCategoryNameFromPreviousVC(categoryName: categoryNameToPass)
            
            editingVC.updateCategoryNameClosure = {
               
                self.viewModel.dataUpdated = {
                    self.categoryTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
//                    self.designFirstAndLastCell()
                }
                
               
                
                self.viewModel.getDataFromCoreData()
                print(self.viewModel.categories)
            }
            
            present(navVC, animated: true)
        }
        
        let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { _ in
            self.showAlert(indexPath: indexPath)
        }
        return UIMenu(children: [editAction, deleteAction])
    }
    
    private func showAlert(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Эта категория точно не нужна", message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self,
                  let cell = self.categoryTableView.cellForRow(at: indexPath),
                  let categoryNameToDelete = cell.textLabel?.text else { return }
            
            self.viewModel.dataUpdated = {
                self.categoryTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                self.designFirstAndLastCell()
            }
            
            self.viewModel.deleteCategory(categoryNameToDelete: categoryNameToDelete)
            
            self.viewModel.getDataFromCoreData()
            self.showPlaceholderForEmptyScreen()
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    func designFirstAndLastCell() {
        let indexPathOfFirstCell = IndexPath(row: 0, section: 0)
        let indexPathOfLastCell = IndexPath(row: viewModel.categories.count - 1, section: 0)
        
        guard let firstCell = self.categoryTableView.cellForRow(at: indexPathOfFirstCell),
              let lastCell = self.categoryTableView.cellForRow(at: indexPathOfLastCell) else { return }
                
        firstCell.layer.cornerRadius = 16
//        firstCell.backgroundColor = .darkGray.withAlphaComponent(0.1)

        firstCell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        firstCell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        lastCell.layer.cornerRadius = 16
        
//        lastCell.backgroundColor = .darkGray.withAlphaComponent(0.1)

        lastCell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        lastCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
    }
}
