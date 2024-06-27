//
//  MovieQuizTests.swift
//  MovieQuizTests
//
//  Created by Mark Balikoti on 19.06.2024.
//

import XCTest

final class MovieQuizTests: XCTestCase {

    struct ArithmeticOperations {
        func addition(num1: Int, num2: Int) -> Int {
            num1 + num2
        }
        func subtraction(num1: Int, num2: Int) -> Int {
            num1 - num2
        }
        func multiplication(num1: Int, num2: Int) -> Int {
            num1 * num2
        }
    }

    func testAddition() throws {
        let arithmeticOperators = ArithmeticOperations()
        let result = arithmeticOperators.addition(num1: 2, num2: 8)
        XCTAssertEqual(result, 10)
    }
    
    
    
    
    
}
