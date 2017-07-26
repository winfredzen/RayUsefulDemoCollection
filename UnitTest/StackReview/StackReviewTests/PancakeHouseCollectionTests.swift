//
//  PancakeHouseCollectionTests.swift
//  StackReview
//
//  Created by Joshua Greene on 11/4/16.
//  Copyright © 2016 Razeware. All rights reserved.
//

import XCTest
@testable import StackReview

class PancakeHouseCollectionTests: XCTestCase {
  
  var collection: PancakeHouseCollection!
  
  override func setUp() {
    super.setUp()
    
    collection = PancakeHouseCollection()
    
    let bundle = Bundle(for: PancakeHouseCollectionTests.self)
    collection.loadPancakeHouses("test_pancake_houses", in: bundle)
  }
  
  func testCollectionHasExpectedItemsCount() {
    
    XCTAssert(collection.count == 3,
              "Collection didn't have expected number of items")
  }
  
  func testFirstPancakeHouseHasExpectedValues() {
    verifyPancakeHouseHasExpectedValues(index: 0)
  }
  
  func testSecondPancakeHouseHasExpectedValues() {
    verifyPancakeHouseHasExpectedValues(index: 1)
  }
  
  func testThirdPancakeHouseHasExpectedValues() {
    verifyPancakeHouseHasExpectedValues(index: 2)
  }
  
  func verifyPancakeHouseHasExpectedValues(index: Int) {
    
    let pancakeHouse = collection[index]
    let plistIndex = index + 1
    
    XCTAssertEqual(pancakeHouse.name, "name \(plistIndex)")
    XCTAssertEqual(pancakeHouse.details, "details \(plistIndex)")
    XCTAssertEqual(pancakeHouse.photo, UIImage(named: "pancake\(plistIndex)"))
  }
  
  // MARK: - Adding/Removing Pancake Houses
  
  func testCanAddPancakeHouse() {
    
    // given
    let dict: [String: Any] = ["name": "Test Pancake House",
                               "priceGuide": 1,
                               "rating": 1,
                               "details": "Test"]
    
    let pancakeHouse = PancakeHouse(dictionary: dict)!
    
    // when
    collection.addPancakeHouse(pancakeHouse)
    
    // then
    XCTAssertTrue(collection._pancakeHouses.contains(pancakeHouse))
  }
  
  func testCanRemovePancakeHouse() {
    
    // given
    let pancakeHouse = collection[0]
    
    // when
    try! collection.removePancakeHouse(pancakeHouse)
    
    // then
    XCTAssertFalse(collection._pancakeHouses.contains(pancakeHouse))
  }
  
  // MARK: - Loading Data Performance
  
  func testMeasureLoadDefaultPancakeHouses() {
    measure {
      self.collection.loadDefaultPancakeHouses()
    }
  }
  
  // MARK: - Favorite Pancake
  
  func testSetFavoritePancake() {
    
    // given
    let pancakeHouse = collection[0]
    let otherPancakeHouse = collection[1]
    
    // when
    collection.favorite = pancakeHouse
    
    // then
    XCTAssertTrue(collection.isFavorite(pancakeHouse))
    XCTAssertFalse(collection.isFavorite(otherPancakeHouse))
  }
  
  func testGivenFavoriteNotInCollectionDoesntSetFavorite() {
    
    // given
    let pancakeHouse = givenNewPancakeHouse()
    
    // when
    collection.favorite = pancakeHouse
    
    // then
    XCTAssertNil(collection.favorite)
  }
  
  func testWhenTryToRemoveFavoriteThrowsExpectedError() {
    
    // given
    let favoritePancakeHouse = collection[0]
    collection.favorite = favoritePancakeHouse
    
    // then
    XCTAssertThrowsError(try collection.removePancakeHouse(favoritePancakeHouse), "Should not be allowed to remove favorite pancake house") {
      let error = $0 as! PancakseHouseError
      XCTAssertEqual(error, PancakseHouseError.triedToRemoveFavoritePancakeHouse)
    }
  }
  
  func testWhenTryToRemoveUnknownFavoriteThrowsExpectedError() {
    
    // given
    let pancakeHouse = givenNewPancakeHouse()
    
    // then
    XCTAssertThrowsError(try collection.removePancakeHouse(pancakeHouse), "Should not be allowed to remove unknown pancake house") {
      let error = $0 as! PancakseHouseError
      XCTAssertEqual(error, PancakseHouseError.triedToRemoveUnknownPancakeHouse)
    }
  }
  
  func givenNewPancakeHouse() -> PancakeHouse {
    let dictionary = ["name": "Test Pancake House", "priceGuide": 1, "rating": 1, "details": "Test"] as [String : Any]
    return PancakeHouse(dictionary: dictionary)!
  }
}
