import XCTest

import createmlfairyTests

var tests = [XCTestCaseEntry]()
tests += createmlfairyTests.allTests()
XCTMain(tests)
