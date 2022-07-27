//
//  TestSearchViewController.swift
//  OutdoorTribeTests
//
//  Created by Jay Chou on 2022/7/21.
//

import XCTest
@testable import OutdoorTribe

class TestSearchViewController: XCTestCase {

    var sut: SearchViewController!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = SearchViewController()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        try super.tearDownWithError()
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testDaysBetweenTwoDate() {
        // given
        let startDate = Date().addingTimeInterval(0)
        let endDate = Date().addingTimeInterval(86400 * 3)
        
        // when
        let dateStrings = sut.daysBetweenTwoDate(startDate: startDate, endDate: endDate)
        // given
        XCTAssertEqual(dateStrings, ["07/21", "07/22", "07/23", "07/24"], "test fail")
        
    }

    
    
}
