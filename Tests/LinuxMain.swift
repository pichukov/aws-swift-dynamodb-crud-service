import XCTest

import DynamoDBServiceTests

var tests = [XCTestCaseEntry]()
tests += DynamoDBServiceTests.allTests()
XCTMain(tests)
