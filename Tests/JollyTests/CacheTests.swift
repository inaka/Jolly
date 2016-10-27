import XCTest
@testable import Jolly

#if os(Linux)
    extension CacheTests {
        static var allTests: [(String, (CacheTests) -> () throws -> Void)] {
            return [
                ("testAddRepo", testAddRepo),
                ("testInitialState", testInitialState),
                ("testRemoveExistentRepo", testRemoveExistentRepo),
                ("testRemoveNonExistentRepo", testRemoveNonExistentRepo),
                ("testReposAreSortedAlphabetically", testReposAreSortedAlphabetically),
                ("testAddAndRemoveReposInDifferentRooms", testAddAndRemoveReposInDifferentRooms)
            ]
        }
    }
#endif

class CacheTests: XCTestCase {
    
    var cache: Cache!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        cache = Cache(defaults: InMemoryUserDefaults())
    }
    
    func testAddRepo() {
        let repo = Repo(fullName: "inaka/jolly")!
        
        cache.add(repo, toRoomWithId: "1")
        
        let savedRepos = cache.repos(forRoomWithId: "1")
        XCTAssertEqual(savedRepos.count, 1)
        XCTAssertEqual(savedRepos[0].fullName, "inaka/jolly")
    }
    
    func testInitialState() {
        let savedRepos = cache.repos(forRoomWithId: "1")
        XCTAssertEqual(savedRepos.count, 0)
    }
    
    func testRemoveExistentRepo() {
        let repo1 = Repo(fullName: "inaka/jolly")!
        let repo2 = Repo(fullName: "inaka/jayme")!

        cache.add(repo1, toRoomWithId: "1")
        cache.add(repo2, toRoomWithId: "1")
        cache.remove(repo1, fromRoomWithId: "1")

        let savedRepos = cache.repos(forRoomWithId: "1")
        XCTAssertEqual(savedRepos.count, 1)
        XCTAssertEqual(savedRepos[0].fullName, "inaka/jayme")
    }
    
    func testRemoveNonExistentRepo() {
        let repo = Repo(fullName: "inaka/jolly")!

        cache.remove(repo, fromRoomWithId: "1")
        
        let savedRepos = cache.repos(forRoomWithId: "1")
        XCTAssertEqual(savedRepos.count, 0)
    }
    
    func testReposAreSortedAlphabetically() {
        let repo1 = Repo(fullName: "inaka/jolly")!
        let repo2 = Repo(fullName: "inaka/jayme")!
        let repo3 = Repo(fullName: "inaka/galgo")!

        cache.add(repo1, toRoomWithId: "1")
        cache.add(repo2, toRoomWithId: "1")
        cache.add(repo3, toRoomWithId: "1")
        
        let savedRepos = cache.repos(forRoomWithId: "1")
        XCTAssertEqual(savedRepos.count, 3)
        XCTAssertEqual(savedRepos[0].fullName, "inaka/galgo")
        XCTAssertEqual(savedRepos[1].fullName, "inaka/jayme")
        XCTAssertEqual(savedRepos[2].fullName, "inaka/jolly")
    }
    
    func testAddAndRemoveReposInDifferentRooms() {
        let repo1 = Repo(fullName: "inaka/jolly")!
        let repo2 = Repo(fullName: "inaka/jayme")!
        let repo3 = Repo(fullName: "inaka/galgo")!
        
        cache.add(repo1, toRoomWithId: "1")
        cache.add(repo2, toRoomWithId: "1")
        cache.add(repo3, toRoomWithId: "1")
        cache.add(repo1, toRoomWithId: "2")
        cache.add(repo3, toRoomWithId: "2")
        cache.add(repo3, toRoomWithId: "3")
        cache.remove(repo3, fromRoomWithId: "2")

        let repos1 = cache.repos(forRoomWithId: "1")
        XCTAssertEqual(repos1.count, 3)
        XCTAssertEqual(repos1[0].fullName, "inaka/galgo")
        XCTAssertEqual(repos1[1].fullName, "inaka/jayme")
        XCTAssertEqual(repos1[2].fullName, "inaka/jolly")
        let repos2 = cache.repos(forRoomWithId: "2")
        XCTAssertEqual(repos2.count, 1)
        XCTAssertEqual(repos2[0].fullName, "inaka/jolly")
        let repos3 = cache.repos(forRoomWithId: "3")
        XCTAssertEqual(repos3.count, 1)
        XCTAssertEqual(repos3[0].fullName, "inaka/galgo")
    }
    
}

class InMemoryUserDefaults: UserDefaults {
    
    private var dict: [String: Any] = [:]
    
    override func set(_ value: Any?, forKey defaultName: String) {
        dict[defaultName] = value
    }
    
    override func array(forKey key: String) -> [Any]? {
        return dict[key] as? [Any]
    }
    
}
