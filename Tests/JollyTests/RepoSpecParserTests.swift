@testable import Jolly
import XCTest
import Foundation

#if os(Linux)
    extension RepoSpecParserTests {
        static var allTests: [(String, (RepoSpecParserTests) -> () throws -> Void)] {
            return [
                ("testParseSuccess", testParseSuccess),
                ("testParseFailure", testParseFailure)
            ]
        }
    }
#endif

class RepoSpecParserTests: XCTestCase {
    
    func testParseSuccess() {
        let dict: [String: Any] = ["html_url": "url",
                                   "full_name": "inaka/jolly",
                                   "stargazers_count": 1,
                                   "forks": 2,
                                   "open_issues_count": 3]
        let spec = RepoSpecParser().repoSpec(from: dict)
        XCTAssertNotNil(spec)
        XCTAssertEqual(spec!.url.absoluteString, "url")
        XCTAssertEqual(spec!.fullName, "inaka/jolly")
        XCTAssertEqual(spec!.stars, 1)
        XCTAssertEqual(spec!.forks, 2)
        XCTAssertEqual(spec!.issues, 3)
    }
    
    func testParseFailure() {
        let dict = [String: Any]()
        let spec = RepoSpecParser().repoSpec(from: dict)
        XCTAssertNil(spec)
    }
    
}
