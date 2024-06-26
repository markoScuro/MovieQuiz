
import XCTest

@testable import MovieQuiz

class ArrayTests: XCTestCase {
    
    func testGetValueInRang() throws {
        
        let array = [1, 3, 2, 8, 2]
        let value = array[safe: 2]
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
        
    }
    
    func testGetValueOutRange() throws {
        
        let array = [1, 2, 3, 4, 5]
        let value = array[safe: 2]
        XCTAssertNil(value)
       
    }
    
}

