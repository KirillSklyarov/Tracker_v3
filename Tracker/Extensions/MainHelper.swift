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
    
    static let arrayOfEmoji = ["🙂","😻","🌺","🐶","❤️","😱",
                               "😇","😡","🥶","🤔","🙌","🍔",
                               "🥦","🏓","🥇","🎸","🏝️","😪",]
    
    static let arrayOfColors = ["#FD4C49", "#FF881E", "#007BFA", "#6E44FE", "#33CF69", "#E66DD4",
                         "#F9D4D4", "#34A7FE", "#46E69D", "#35347C", "#FF674D", "#FF99CC",
                         "#F6C48B", "#7994F5", "#832CF1", "#AD56DA", "#8D72E6", "#2FD058"]
    
}
