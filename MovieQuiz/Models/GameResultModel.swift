//
//  GameRecordModel.swift
//  MovieQuiz
//
//  Created by Mark Balikoti on 24.05.2024.
//

import Foundation

struct GameResult: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
