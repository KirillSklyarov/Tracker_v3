//
//  StatisticViewModelProtocol.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 11.04.2024.
//

import Foundation

protocol StatisticViewModelProtocol {
    
    var bestPeriod: Int { get set }
    var idealDays: Int { get set }
    var completedTrackers: Int { get set }
    var averageNumber: Double { get set }
    
    var updateData: ( () -> Void )? { get set}
    
    func isStatisticsEmpty() -> Bool
    func countOfCompletedTrackers()
    func trackerRecordsPerDay()
    
    func deleleAllRecords()
    func calculationOfIdealDays()
    func calculateTheBestPeriod()
        
}
