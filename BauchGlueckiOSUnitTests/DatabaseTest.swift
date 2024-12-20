//
//  BauchGlueckiOSUnitTests.swift
//  BauchGlueckiOSUnitTests
//
//  Created by Frederik Kohler on 26.11.24.
//
import XCTest
import Testing
import SwiftData
@testable import BauchGlueckiOS

struct BauchGlueckiOSUnitTests {
    @Test(
        "Test valid email",
        arguments: [
            "abc123@gmail.com",
            "abc123gmail.com",
            "abc123@.com"
        ]
    ) func testValidEmail(email: String) throws {
        #expect(email.contains("@") && email.contains("."), "Invalid email format")
    }
    
    @Test("DatabaseTest", arguments: [nil, "NotNil"])
    func test(string: String?) {
        // GIVEN
        let inputString = string
        
        // WHEN
        let isNotNil = (inputString != nil)
        
        // THEN
        #expect(isNotNil, "Erwartet wurde ein nicht-nil String, aber es war nil.")
    }
}
