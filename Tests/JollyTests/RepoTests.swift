import XCTest
@testable import Jolly

#if os(Linux)
    extension RepoTests {
        static var allTests: [(String, (CacheTests) -> () throws -> Void)] {
            return [
                ("testProperFormat", testProperFormat),
                ("testWrongFormatNoSlashes", testWrongFormatNoSlashes),
                ("testWrongFormatTooManySlashes", testWrongFormatTooManySlashes)
            ]
        }
    }
#endif

class RepoTests: XCTestCase {
    
    func testProperFormat() {
        let repo = Repo(fullName: "just/right")
        XCTAssertNotNil(repo)
        XCTAssertEqual(repo!.name, "right")
        XCTAssertEqual(repo!.organization, "just")
    }
    
    func testWrongFormatNoSlashes() {
        let repo = Repo(fullName: "insufficient")
        XCTAssertNil(repo)
    }
    
    func testWrongFormatTooManySlashes() {
        let repo = Repo(fullName: "too/many/slashes")
        XCTAssertNil(repo)
    }
    
}
