import XCTest
@testable import Jolly

class RepoTests: XCTestCase {
    
    func testConstructorSuccess() {
        let repo = Repo(fullName: "just/right")
        XCTAssertNotNil(repo)
        XCTAssertEqual(repo!.name, "right")
        XCTAssertEqual(repo!.organization, "just")
    }
    
    func testConstructorFailure() {
        let repo = Repo(fullName: "insufficient")
        XCTAssertNil(repo)
    }
    
    func testAnotherConstructorFailure() {
        let repo = Repo(fullName: "too/much/slashes")
        XCTAssertNil(repo)
    }
    
}
