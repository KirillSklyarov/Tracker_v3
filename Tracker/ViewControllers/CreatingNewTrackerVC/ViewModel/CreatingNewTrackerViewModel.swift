//
//  CreatingNewTrackerViewModel.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 09.04.2024.
//

import Foundation

final class CreatingNewTrackerViewModel: CreatingNewTrackerViewModelProtocol {

    var tableViewRows = [SGen.category, SGen.schedule]

    var arrayOfEmoji = MainHelper.arrayOfEmoji

    var arrayOfColors = MainHelper.arrayOfColors

    let coreDataManager = TrackerCoreManager.shared

    var trackerName: String? {
        didSet {
            isDoneButtonEnable?()
        }
    }

    var selectedEmoji: String? {
        didSet {
            isDoneButtonEnable?()
        }
    }

    var selectedColor: String? {
        didSet {
            isDoneButtonEnable?()
        }
    }

    var selectedCategory: String? {
        didSet {
            isDoneButtonEnable?()
        }
    }

    var selectedSchedule: String? {
        didSet {
            isDoneButtonEnable?()
        }
    }

    var isDoneButtonEnable: ( () -> Void )?

    func getBackToMainScreen() {
        let cancelCreatingTrackerNotification = Notification.Name("cancelCreatingTracker")
        NotificationCenter.default.post(name: cancelCreatingTrackerNotification, object: nil)
    }

    func createNewTracker() {
        guard let name = trackerName,
              let category = selectedCategory,
              let color = selectedColor,
              let emoji = selectedEmoji,
              let schedule = selectedSchedule else {
            print("Smth's going wrong here"); return
        }

        let newTask = TrackerCategory(header: category,
                                      trackers: [Tracker(id: UUID(),
                                                    name: name,
                                                    color: color,
                                                    emoji: emoji,
                                                    schedule: schedule
//                                                    isPinned: false
                                                        )
                                      ])
        coreDataManager.createNewTracker(newTracker: newTask)
        getBackToMainScreen()
    }

    func isAllFieldsFilled() -> Bool {
        let allFieldsFilled =
        trackerName != nil &&
        trackerName != "" &&
        selectedCategory != nil &&
        selectedSchedule != nil &&
        selectedEmoji != nil &&
        selectedColor != nil
        return allFieldsFilled
    }
}
