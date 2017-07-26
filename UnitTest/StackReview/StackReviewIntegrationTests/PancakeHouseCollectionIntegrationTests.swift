//
//  PancakeHouseCollectionIntegrationTests.swift
//  StackReview
//
//  Created by Joshua Greene on 11/5/16.
//  Copyright © 2016 Razeware. All rights reserved.
//

import XCTest
@testable import StackReview

class PancakeHouseCollectionIntegrationTests: XCTestCase {
  
  var collection: PancakeHouseCollection!
  
  override func setUp() {
    super.setUp()
    collection = PancakeHouseCollection()
  }
  
  func testLoadPancakesFromCloudFails() {
    
    // given
    let expectation = self.expectation(description: "Expected load pancakes from cloud to fail")
    
    // when
    collection.loadPancakesFromCloud { (didReceiveData) in
      
      expectation.fulfill()
      XCTAssertFalse(didReceiveData)
    }
    
    // then
    waitForExpectations(timeout: 3, handler: nil)
  }
  
  func testGivenMockCloudNetworkServiceLoadPancakesFromCloudSucceeds() {
    
    // given
    let mockCloudNetworkService = MockCloudNetworkService()
    collection._cloudNetworkManager = mockCloudNetworkService
    
    let expecation = expectation(description: "Expected load pancakes from cloud to succeed")
    
    // when
    collection.loadPancakesFromCloud { (didReceiveData) in
      expecation.fulfill()
      
      XCTAssertTrue(didReceiveData)
      XCTAssertEqual(self.collection._pancakeHouses, mockCloudNetworkService.pancakeHouses)
    }
    
    // then
    waitForExpectations(timeout: 0.1, handler: nil)
  }
  
  
}
