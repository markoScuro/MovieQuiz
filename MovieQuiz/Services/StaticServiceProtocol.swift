//
//  StaticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Mark Balikoti on 24.05.2024.
//

import UIKit

protocol StatisticService {
    
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    
    func store(correct count: Int, total amount: Int)
}
