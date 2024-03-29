import XCTest
import Foundation
import Testing
import HTTP
import Crypto
@testable import Vapor
@testable import App

/// This file shows an example of testing 
/// routes through the Droplet.

class RouteTests: TestCase {
    let drop = try! Droplet.testable()
    
    func testHello() throws {
        try drop
            .testResponse(to: .get, at: "hello")
            .assertStatus(is: .ok)
            .assertJSON("hello", equals: "world")
    }

    func testInfo() throws {
        try drop
            .testResponse(to: .get, at: "info")
            .assertStatus(is: .ok)
            .assertBody(contains: "0.0.0.0")
    }
    
    func testExample() {
        
        
        
        //let expect = expectation(description: "should get json")
        
        //Ripple(drop: drop).balance(address:"rNhd9kzNBS4foYxm6NLHBj5Ve3XPVeBo2k")
        
        //expect.fulfill()
        //waitForExpectations(timeout: 10, handler: nil)
        //
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
}

// MARK: Manifest

extension RouteTests {
    /// This is a requirement for XCTest on Linux
    /// to function properly.
    /// See ./Tests/LinuxMain.swift for examples
    static let allTests = [
        ("testHello", testHello),
        ("testInfo", testInfo),
    ]
}
