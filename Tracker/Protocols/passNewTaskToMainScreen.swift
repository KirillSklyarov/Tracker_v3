//
//  passNewTaskToMainScreen.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 19.03.2024.
//

import Foundation

protocol newTaskDelegate {
    func getNewTaskFromAnotherVC(newTask: TrackerCategory)
}
