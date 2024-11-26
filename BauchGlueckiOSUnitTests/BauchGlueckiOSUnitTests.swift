//
//  BauchGlueckiOSUnitTests.swift
//  BauchGlueckiOSUnitTests
//
//  Created by Frederik Kohler on 26.11.24.
//

import Testing
import SwiftData
import BauchGlueckiOS

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

}
