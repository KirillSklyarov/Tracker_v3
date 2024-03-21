//
//  passNewTaskToMainScreen.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 19.03.2024.
//

import Foundation

protocol NewTaskDelegate: AnyObject {
    func getNewTaskFromAnotherVC(newTask: TrackerCategory)
}
