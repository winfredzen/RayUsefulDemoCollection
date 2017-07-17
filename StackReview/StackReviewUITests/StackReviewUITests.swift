//
//  StackReviewUITests.swift
//  StackReviewUITests
//
//  Created by Joshua Greene on 11/17/16.
//  Copyright © 2016 Razeware. All rights reserved.
//

import XCTest

class StackReviewUITests: XCTestCase {
  
  var app: XCUIApplication!
  
  var horizontalSizeClass: XCUIUserInterfaceSizeClass {
    return app.windows.element(boundBy: 0).horizontalSizeClass
  }
  
  override func setUp() {
    super.setUp()
    
    continueAfterFailure = false
    
    app = XCUIApplication()
    app.launch()
  }
  
  func testCanNavigateToAboutScreen() {
    
    tapPancakeHousesButtonIfNeeded()
    
    let aboutButton = app.navigationBars.buttons["About"]
    aboutButton.tap()
    
    let aboutTitleText = app.navigationBars.staticTexts["About"]
    XCTAssertTrue(aboutTitleText.exists,
                  "Should be on the about screen")
  }
  
  func testCanNavigateToPancakeHouseScreen() {
    
    tapPancakeHousesButtonIfNeeded()
    
    let tableText = app.tables.staticTexts["Stack 'em High"]
    let pancakeText = app.staticTexts["Stack 'em High"]
    let map = app.maps.element
    
    tableText.tap()
    
    XCTAssertTrue(pancakeText.exists)
    XCTAssertTrue(map.exists)
  }
  
  func testPancakeHouseScreenHasScrollView() {
    
    tapPancakeHousesButtonIfNeeded()
    
    let tablesQuery = app.tables
    tablesQuery.cells.staticTexts["Batter 'n Griddle"].swipeUp()
    tablesQuery.cells.staticTexts["Maison des Crêpes"].tap()
    
    XCTAssertEqual(app.scrollViews.count, 1)
  }
  
  func testAboutDetailsCanHideShowCopyrightNotice() {
    
    tapPancakeHousesButtonIfNeeded()
    app.navigationBars.buttons["About"].tap()
    
    let showHideCopyrightNoticeButton = app.buttons["Show/Hide Copyright Notice"]
    showHideCopyrightNoticeButton.tap()
    
    XCTAssertTrue(app.images["rw_logo"].exists)
    
    showHideCopyrightNoticeButton.tap()
    XCTAssertFalse(app.images["rw_logo"].exists)
  }
  
  func tapPancakeHousesButtonIfNeeded() {
    guard horizontalSizeClass != .regular else { return }
    let pancakeHouseButton = app.navigationBars.buttons["Pancake Houses"]
    pancakeHouseButton.tap()
  }
}
