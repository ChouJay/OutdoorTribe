//
//  OutdoorTribeTests.swift
//  OutdoorTribeTests
//
//  Created by Jay Chou on 2022/7/20.
//

import XCTest
@testable import OutdoorTribe

class OutdoorTribeTests: XCTestCase {

    var sut: CalendarPickerViewController!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = CalendarPickerViewController(todayDate: Date())
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
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testGenerateDay() {
        // given
        let todayDate = Date()
        let dayOffset = 5
        let iswithinDisplayMonth = false

        // when
        let day = sut.generateDay(offsetBy: dayOffset, for: todayDate, isWithinDisplayedMonth: iswithinDisplayMonth)

        // then
        XCTAssertEqual(day.number, "25", "wrong")
    }
    
    func testDrawCellInChooseDateRangeBeFilled() {
        // given
        let day = Day(date: Date(), number: "20", isSelectable: true, isWithinDisplayedMonth: true)
        let dateRange = [Date(timeInterval: -86400, since: Date()), Date(timeInterval: 86400, since: Date())]
        let cell = CalendarCollectionCell()
        
        // when
        let returnCell = sut.drawCellInChooseDateRange(for: cell, day: day, in: dateRange)
        
        // then
        XCTAssertTrue(returnCell.isInRange)
        
    }
    
    func testDrawCellInChooseDateRangeBeHalfFilled() {
        // given
        let day = Day(date: Date(), number: "20", isSelectable: true, isWithinDisplayedMonth: true)
        let dateRange = [Date(timeInterval: 0, since: Date()), Date(timeInterval: 86400, since: Date())]
        let cell = CalendarCollectionCell()
        
        // when
        let returnCell = sut.drawCellInChooseDateRange(for: cell, day: day, in: dateRange)
            
        // then
        XCTAssertTrue(returnCell.rangeLeftView.isHidden)
    }
}
