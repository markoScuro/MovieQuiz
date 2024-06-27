
import UIKit

final class StatisticServiceImplementation: StatisticService {
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        self.correct += count
        totalAccuracy = Double(correct) / (Double(gamesCount) * Double(amount)) * 100;
        
        let previousResult = self.bestGame
        let newResult = GameResult(correct: count, total: amount, date: Date())
        if newResult.isBetterThan(previousResult) {
            self.bestGame = newResult
        }
    }
    
    private let userDefaults = UserDefaults.standard
    
    var totalAccuracy: Double {
        get {
            guard let data = userDefaults.data(forKey: Keys.total.rawValue),
                  let record = try? JSONDecoder().decode(Double.self, from: data)
            else {
                return 0
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.total.rawValue)
        }
    }
    
    var correct: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.correct.rawValue),
                  let record = try? JSONDecoder().decode(Int.self, from: data)
            else {
                return 0
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.correct.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.gamesCount.rawValue),
                  let record = try? JSONDecoder().decode(Int.self, from: data)
            else {
                return 0
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameResult.self, from: data)
            else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
}

