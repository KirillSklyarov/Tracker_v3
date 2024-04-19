//
//  ScheduleViewModel.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 08.04.2024.
//

import Foundation

final class ScheduleViewModel {
    
    let rowHeight = CGFloat(75)
    
    let weekdays = ["Monday".localized(),
                    "Tuesday".localized(),
                    "Wednesday".localized(),
                    "Thursday".localized(),
                    "Friday".localized(),
                    "Saturday".localized(),
                    "Sunday".localized(),
    ]
    
    var tableViewHeight: CGFloat {
        CGFloat(weekdays.count) * rowHeight
    }
    
    var arrayOfIndexes = [Int]()
    
    var scheduleToPass: ( (String) -> Void )?
    
    func appendOrRemoveArray(sender: Bool, indexPath: IndexPath) {
        if sender == true {
            self.arrayOfIndexes.append(indexPath.row)
        } else {
            self.arrayOfIndexes.removeAll(where: { $0 == indexPath.row })
        }
    }
    
    func passScheduleToCreatingTrackerVC() {
        var resultString = String()
        
        if arrayOfIndexes.count == 7 {
            resultString = "Everyday".localized()
        } else {
            let daysOfWeek = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
            let arrayOfStrings = arrayOfIndexes.map { daysOfWeek[$0] }
            resultString = arrayOfStrings.joined(separator: ", ")
        }
        
        scheduleToPass?(resultString)
    }
    
}
