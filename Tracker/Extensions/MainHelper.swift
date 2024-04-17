//
//  MainHelper.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 16.04.2024.
//

import UIKit

struct MainHelper {
    
    static func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        let dateToString = formatter.string(from: date)
        return dateToString
    }
    
    static func stringToDate(string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        let stringToDate = formatter.date(from: string)
        return stringToDate
    }
}
