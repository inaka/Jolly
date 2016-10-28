@testable import Jolly
import XCTest
import Foundation

#if os(Linux)
    extension CommandRouterTests {
        static var allTests: [(String, (CommandRouterTests) -> () throws -> Void)] {
            return [
                ("testCommandJolly", testCommandJolly),
                ("testCommandAbout", testCommandAbout),
                ("testCommandPing", testCommandPing),
                ("testCommandList", testCommandList),
                ("testCommandReport", testCommandReport),
                ("testCommandClear", testCommandClear),
                ("testCommandWatch", testCommandWatch),
                ("testCommandUnwatch", testCommandUnwatch),
                ("testCommandWatchValidRepo", testCommandWatchValidRepo),
                ("testCommandWatchInvalidRepoFormat", testCommandWatchInvalidRepoFormat),
                ("testCommandWatchValidRepoThatIsAlreadyBeingWatched", testCommandWatchValidRepoThatIsAlreadyBeingWatched),
                ("testCommandWatchNonExistentRepo", testCommandWatchNonExistentRepo),
                ("testCommandUnwatchRepoThatIsBeingWatched", testCommandUnwatchRepoThatIsBeingWatched),
                ("testCommandUnwatchRepoThatIsNotBeingWatched", testCommandUnwatchRepoThatIsNotBeingWatched),
                ("testCommandUnwatchInvalidRepoFormat", testCommandUnwatchInvalidRepoFormat),
                ("testCommandYoDawg", testCommandYoDawg),
                ("testCommandUnknown", testCommandUnknown),
                ("testErrorSendingNotification", testErrorSendingNotification),
                ("testErrorFetchingRepoSpecsWhileCreatingReport", testErrorFetchingRepoSpecsWhileCreatingReport),
                ("testNotSlashJollyCommand", testNotSlashJollyCommand)
            ]
        }
    }
#endif

class CommandRouterTests: XCTestCase {
    
    var router: CommandRouter! // SUT
    
    var sender: FakeNotificationSender!
    var cache: FakeCache!
    var provider: FakeRepoSpecProvider!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        sender = FakeNotificationSender(roomId: "1", authenticationToken: "xxx")
        
        let repos1 = [Repo(fullName: "watched/repo1")!,
                     Repo(fullName: "watched/repo2")!,
                     Repo(fullName: "watched/repo3")!]
        
        let repos2 = [Repo(fullName: "watched/repo3")!,
                      Repo(fullName: "watched/repo4")!,]
        
        cache = FakeCache(reposForRoom1: repos1, reposForRoom2: repos2)
        provider = FakeRepoSpecProvider()
        
        router = CommandRouter(notificationSender: sender,
                               repoSpecProvider: provider,
                               cache: cache)
    }
    
    func testCommandJolly() {
        let future = router.handle("/jolly")
        let expectation = self.expectation(description: "Expected")
        future.start() { result in
            guard
                case .success = result,
                let notification = self.sender.notification
                else { XCTFail(); return }
            XCTAssertGreaterThan(notification.message.text.characters.count, 1)
            XCTAssertNotEqual(notification.color, .red)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testCommandAbout() {
        let future = router.handle("/jolly about")
        let expectation = self.expectation(description: "Expected")
        future.start() { result in
            guard
                case .success = result,
                let notification = self.sender.notification
                else { XCTFail(); return }
            XCTAssertGreaterThan(notification.message.text.characters.count, 1)
            XCTAssertNotEqual(notification.color, .red)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testCommandPing() {
        let future = router.handle("/jolly ping")
        let expectation = self.expectation(description: "Expected")
        future.start() { result in
            guard
                case .success = result,
                let notification = self.sender.notification
                else { XCTFail(); return }
            XCTAssertTrue(notification.message.text.lowercased().contains("pong"))
            XCTAssertNotEqual(notification.color, .red)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testCommandList() {
        let future = router.handle("/jolly list")
        let expectation = self.expectation(description: "Expected")
        future.start() { result in
            guard
                case .success = result,
                let notification = self.sender.notification
                else { XCTFail(); return }
            
            let text = notification.message.text
            XCTAssertNotEqual(notification.color, .red)
            XCTAssertTrue(text.contains("watched/repo1"))
            XCTAssertTrue(text.contains("watched/repo2"))
            XCTAssertTrue(text.contains("watched/repo3"))
            XCTAssertFalse(text.contains("watched/repo4"))
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testCommandReport() {
        let future = router.handle("/jolly report")
        let expectation = self.expectation(description: "Expected")
        future.start() { result in
            guard
                case .success = result,
                let notification = self.sender.notification
                else { XCTFail(); return }
            
            let text = notification.message.text
            XCTAssertNotEqual(notification.color, .red)
            XCTAssertTrue(text.contains("watched/repo1"))
            XCTAssertTrue(text.contains("watched/repo2"))
            XCTAssertTrue(text.contains("watched/repo3"))
            XCTAssertFalse(text.contains("watched/repo4"))
            XCTAssertTrue(text.contains("123")) // # of stars
            XCTAssertTrue(text.contains("456")) // # of forks
            XCTAssertTrue(text.contains("789")) // # of issues
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testCommandClear() {
        let future = router.handle("/jolly clear")
        let expectation = self.expectation(description: "Expected")
        future.start() { result in
            guard
                case .success = result,
                let notification = self.sender.notification
                else { XCTFail(); return }
            
            XCTAssertNotEqual(notification.color, .red)
            XCTAssertEqual(self.cache.removed.count, 3)
            XCTAssertEqual(self.cache.removed[0].0.fullName, "watched/repo1")
            XCTAssertEqual(self.cache.removed[1].0.fullName, "watched/repo2")
            XCTAssertEqual(self.cache.removed[2].0.fullName, "watched/repo3")
            XCTAssertEqual(self.cache.removed[0].roomId, "1")
            XCTAssertEqual(self.cache.removed[1].roomId, "1")
            XCTAssertEqual(self.cache.removed[2].roomId, "1")
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testCommandWatch() {
        let future = router.handle("/jolly watch")
        let expectation = self.expectation(description: "Expected")
        future.start() { result in
            guard
                case .success = result,
                let notification = self.sender.notification
                else { XCTFail(); return }
            
            XCTAssertNotEqual(notification.color, .red)
            XCTAssertNotEqual(notification.color, .green)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }

    func testCommandUnwatch() {
        let future = router.handle("/jolly unwatch")
        let expectation = self.expectation(description: "Expected")
        future.start() { result in
            guard
                case .success = result,
                let notification = self.sender.notification
                else { XCTFail(); return }
            
            XCTAssertNotEqual(notification.color, .red)
            XCTAssertNotEqual(notification.color, .green)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testCommandWatchValidRepo() {
        let future = router.handle("/jolly watch nonwatched/ValidRepo")
        let expectation = self.expectation(description: "Expected")
        future.start() { result in
            guard
                case .success = result,
                let notification = self.sender.notification
                else { XCTFail(); return }
            
            let text = notification.message.text
            XCTAssertEqual(notification.color, .green)
            XCTAssertTrue(text.contains("nonwatched/ValidRepo"))
            XCTAssertEqual(self.cache.removed.count, 0)
            XCTAssertEqual(self.cache.added.count, 1)
            XCTAssertEqual(self.cache.added[0].0.fullName, "nonwatched/ValidRepo")
            XCTAssertEqual(self.cache.added[0].roomId, "1")
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testCommandWatchInvalidRepoFormat() {
        let future = router.handle("/jolly watch wrong/repo/format")
        let expectation = self.expectation(description: "Expected")
        future.start() { result in
            guard
                case .success = result,
                let notification = self.sender.notification
                else { XCTFail(); return }
            
            let text = notification.message.text
            XCTAssertEqual(notification.color, .red)
            XCTAssertTrue(text.contains("format"))
            XCTAssertEqual(self.cache.removed.count, 0)
            XCTAssertEqual(self.cache.added.count, 0)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testCommandWatchValidRepoThatIsAlreadyBeingWatched() {
        let future = router.handle("/jolly watch watched/repo1")
        let expectation = self.expectation(description: "Expected")
        future.start() { result in
            guard
                case .success = result,
                let notification = self.sender.notification
                else { XCTFail(); return }
            
            let text = notification.message.text
            XCTAssertNotEqual(notification.color, .red)
            XCTAssertTrue(text.contains("watched/repo1"))
            XCTAssertEqual(self.cache.removed.count, 0)
            XCTAssertEqual(self.cache.added.count, 0)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testCommandWatchNonExistentRepo() {
        provider.shouldReturnValidSpecs = false
        let future = router.handle("/jolly watch private/repo")
        let expectation = self.expectation(description: "Expected")
        future.start() { result in
            guard
                case .success = result,
                let notification = self.sender.notification
                else { XCTFail(); return }
            
            let text = notification.message.text
            XCTAssertEqual(notification.color, .red)
            XCTAssertTrue(text.contains("private/repo"))
            XCTAssertEqual(self.cache.added.count, 0)
            XCTAssertEqual(self.cache.removed.count, 0)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testCommandUnwatchRepoThatIsBeingWatched() {
        let future = router.handle("/jolly unwatch watched/repo1")
        let expectation = self.expectation(description: "Expected")
        future.start() { result in
            guard
                case .success = result,
                let notification = self.sender.notification
                else { XCTFail(); return }
            
            let text = notification.message.text
            XCTAssertEqual(notification.color, .green)
            XCTAssertTrue(text.contains("watched/repo1"))
            XCTAssertEqual(self.cache.added.count, 0)
            XCTAssertEqual(self.cache.removed.count, 1)
            XCTAssertEqual(self.cache.removed[0].0.fullName, "watched/repo1")
            XCTAssertEqual(self.cache.removed[0].roomId, "1")
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testCommandUnwatchRepoThatIsNotBeingWatched() {
        provider.shouldReturnValidSpecs = false
        let future = router.handle("/jolly unwatch nonwatched/repo1")
        let expectation = self.expectation(description: "Expected")
        future.start() { result in
            guard
                case .success = result,
                let notification = self.sender.notification
                else { XCTFail(); return }
            
            let text = notification.message.text
            XCTAssertEqual(notification.color, .red)
            XCTAssertTrue(text.contains("nonwatched/repo1"))
            XCTAssertEqual(self.cache.added.count, 0)
            XCTAssertEqual(self.cache.removed.count, 0)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testCommandUnwatchInvalidRepoFormat() {
        let future = router.handle("/jolly unwatch wrong/repo/format")
        let expectation = self.expectation(description: "Expected")
        future.start() { result in
            guard
                case .success = result,
                let notification = self.sender.notification
                else { XCTFail(); return }
            
            let text = notification.message.text
            XCTAssertEqual(notification.color, .red)
            XCTAssertTrue(text.contains("format"))
            XCTAssertEqual(self.cache.removed.count, 0)
            XCTAssertEqual(self.cache.added.count, 0)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testCommandYoDawg() {
        let future = router.handle("/jolly jolly")
        let expectation = self.expectation(description: "Expected")
        future.start() { result in
            guard
                case .success = result,
                let notification = self.sender.notification
                else { XCTFail(); return }
            XCTAssertTrue(notification.message.text.lowercased().contains("yodawg"))
            XCTAssertNotEqual(notification.color, .red)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testCommandUnknown() {
        let future = router.handle("/jolly what the heck")
        let expectation = self.expectation(description: "Expected")
        future.start() { result in
            guard
                case .success = result,
                let notification = self.sender.notification
                else { XCTFail(); return }
            
            let text = notification.message.text
            XCTAssertTrue(text.lowercased().contains("/jolly what the heck"))
            XCTAssertEqual(notification.color, .red)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testErrorSendingNotification() {
        sender.shouldGetNotificationDeliveryFailure = true
        let future = router.handle("/jolly watch inaka/jayme")
        let expectation = self.expectation(description: "Expected")
        future.start() { result in
            guard case .failure(let error) = result
                else { XCTFail(); return }
            XCTAssertEqual(error, .errorSendingNotification)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testErrorFetchingRepoSpecsWhileCreatingReport() {
        provider.shouldReturnValidSpecs = false
        let future = router.handle("/jolly report")
        let expectation = self.expectation(description: "Expected")
        future.start() { result in
            guard case .failure(let error) = result
                else { XCTFail(); return }
            XCTAssertEqual(error, .errorFetchingRepoSpecs)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testNotSlashJollyCommand() {
        let future = router.handle("/jolly_nope whatever")
        let expectation = self.expectation(description: "Expected")
        future.start() { result in
            guard case .failure(let error) = result
                else { XCTFail(); return }
            XCTAssertEqual(error, .notSlashJollyCommand)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
}

class FakeNotificationSender: NotificationSender {
    
    var notification: Jolly.Notification?
    var shouldGetNotificationDeliveryFailure = false
    
    override func send(_ notification: Jolly.Notification) -> Future<Void, NotificationSender.Error> {
        self.notification = notification
        return Future() { completion in
            if self.shouldGetNotificationDeliveryFailure {
                completion(.failure(.responseError))
            } else {
                completion(.success())
            }
        }
    }
    
}

class FakeCache: Cache {
    
    // Logs added and removed repos
    private(set) var added = [(Repo, roomId: String)]()
    private(set) var removed = [(Repo, roomId: String)]()
    
    // I can set whatever I want to return
    let reposForRoom1: [Repo]
    let reposForRoom2: [Repo]
    
    init(reposForRoom1 repos1: [Repo], reposForRoom2 repos2: [Repo]) {
        self.reposForRoom1 = repos1
        self.reposForRoom2 = repos2
    }
    
    override func add(_ repo: Repo, toRoomWithId roomId: String) {
        self.added += [(repo, roomId: roomId)]
    }
    
    override func remove(_ repo: Repo, fromRoomWithId roomId: String) {
        self.removed += [(repo, roomId: roomId)]
    }

    override func repos(forRoomWithId roomId: String) -> [Repo] {
        switch roomId {
        case "1": return reposForRoom1
        case "2": return reposForRoom2
        default: return [Repo]()
        }
    }
    
}

class FakeRepoSpecProvider: RepoSpecProvider {
    
    var shouldReturnValidSpecs = true
    
    override func fetchSpec(for repo: Repo) -> Future<RepoSpec, RepoSpecProvider.Error> {
        return Future() { completion in
            if self.shouldReturnValidSpecs {
                let spec = RepoSpec(url: URL(string: "X")!,
                                    fullName: repo.fullName,
                                    stars: 123, forks: 456, issues: 789)
                completion(.success(spec))
            } else {
                completion(.failure(.dataError))
            }
        }
    }
    
    override func fetchSpecs(for repos: [Repo]) -> Future<[RepoSpec], RepoSpecProvider.Error> {
        return Future() { completion in
            if self.shouldReturnValidSpecs {
                let specs = repos.map {
                    RepoSpec(url: URL(string: "X")!,
                             fullName: $0.fullName,
                             stars: 123, forks: 456, issues: 789)
                }
                completion(.success(specs))
            } else {
                completion(.failure(.dataError))
            }
        }
    }
    
}
