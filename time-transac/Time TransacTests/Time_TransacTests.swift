//
//  Time_TransacTests.swift
//  Time TransacTests
//
//  Created by Gbenga Ayobami on 2017-06-06.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//

import XCTest
@testable import Time_Transac

class Time_TransacTests: XCTestCase {
    
    var intface: AllJobs!
    var john: User!
    var bill: User!
    
    override func setUp() {
        super.setUp()
        
        john = User(firstName: "John", lastName: "Bull", email: "john@mail.com", password: "111", country: "canada", city: "toronto", province_State: "ontario", postal_ZipCode: "l5l5b7")
        
        bill = User(firstName: "Bill", lastName: "clinton", email: "bill@mail.com", password: "000", country: "USA", city: "chicago", province_State: "Illinois", postal_ZipCode: "m6m5b7")
        
        intface = AllJobs.allPostedJobs
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        john = nil
        bill = nil
        intface = nil
    }
    
    
    func testApp(){

        
    }
    
    
}




















