import XCTest
@testable import Jolly

#if os(Linux)
    extension RepoSpecProviderTests {
        static var allTests: [(String, (CacheTests) -> () throws -> Void)] {
            return [
                ("testFetchSpecsRequestMethod", testFetchSpecsRequestMethod),
                ("testFetchSpecsRequestHeaderFields", testFetchSpecsRequestHeaderFields),
                ("testFetchSpecsRequestPath", testFetchSpecsRequestPath),
                ("testFetchMultipleSpecsNoRepos", testFetchMultipleSpecsNoRepos),
                ("testFetchMultipleSpecsResponseSuccess", testFetchMultipleSpecsResponseSuccess),
                ("testFetchMultipleSpecsResponseFailure", testFetchMultipleSpecsResponseFailure)
            ]
        }
    }
#endif

class RepoSpecProviderTests: XCTestCase {
    
    var provider: RepoSpecProvider!
    var session: FakeURLSession!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        session = FakeURLSession()
        provider = RepoSpecProvider(urlSession: session)
    }
    
    func testFetchSpecsRequestMethod() {
        let repos = [Repo(fullName: "doesnt/matter")!]
        provider.fetchSpecs(for: repos).start() { _ in }
        let request = session.dataTasks.first?.request
        XCTAssertNotNil(request)
        XCTAssertEqual(request!.httpMethod, "GET")
    }
    
    func testFetchSpecsRequestHeaderFields() {
        let repos = [Repo(fullName: "doesnt/matter")!]
        provider.fetchSpecs(for: repos).start() { _ in }
        let request = session.dataTasks.first?.request
        XCTAssertNotNil(request)
        XCTAssertEqual(request!.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(request!.value(forHTTPHeaderField: "Accept"), "application/vnd.github.v3+json")
    }

    func testFetchSpecsRequestPath() {
        let repos = [Repo(fullName: "inaka/jolly")!]
        provider.fetchSpecs(for: repos).start() { _ in }
        let url = session.dataTasks.first?.request?.url
        XCTAssertNotNil(url)
        XCTAssertEqual(url!.absoluteString, "https://api.github.com/repos/inaka/jolly")
    }
    
    func testFetchMultipleSpecsNoRepos() {
        let repos = [Repo]()
        let future = provider.fetchSpecs(for: repos)
        let expectation = self.expectation(description: "Expected .success")
        future.start() { result in
            guard case .success = result else { XCTFail(); return }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testFetchMultipleSpecsResponseSuccess() {
        let json = ["k": "v"]
        let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        XCTAssertNotNil(data)
        let params: DataTaskCompletionParameters = (data!, URLResponse(), nil)
        let session = FakeURLSession(customDataTaskCompletionParameters: params)
        let parser = FakeRepoSpecParser()
        let provider = RepoSpecProvider(urlSession: session, parser: parser)
        let repos = [Repo(fullName: "doesnt/matter")!, Repo(fullName: "doesnt/matter_either")!]
        let future = provider.fetchSpecs(for: repos)
        let expectation = self.expectation(description: "Expected .success with 2 specs")
        future.start() { result in
            guard case .success(let specs) = result
                else { XCTFail(); return }
            XCTAssertEqual(specs.count, 2)
            XCTAssertEqual(parser.parsedDictionaries.count, 2)
            let val1 = (parser.parsedDictionaries[0]["k"] as? String)
            XCTAssertNotNil(val1)
            XCTAssertEqual(val1, "v")
            let val2 = (parser.parsedDictionaries[1]["k"] as? String)
            XCTAssertNotNil(val2)
            XCTAssertEqual(val2, "v")
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testFetchMultipleSpecsResponseFailure() {
        let error = NSError(domain: "doesn't matter", code: 0, userInfo: nil)
        let params: DataTaskCompletionParameters = (nil, nil, error)
        let session = FakeURLSession(customDataTaskCompletionParameters: params)
        let provider = RepoSpecProvider(urlSession: session)
        let repos = [Repo(fullName: "doesnt/matter")!, Repo(fullName: "doesnt/matter_either")!]
        let future = provider.fetchSpecs(for: repos)
        let expectation = self.expectation(description: "Expected .success with no specs")
        future.start() { result in
            guard case .success(let specs) = result
                else { XCTFail(); return }
            XCTAssertEqual(specs.count, 0)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
}

class FakeRepoSpecParser: RepoSpecParser {
    
    var parsedDictionaries = [[String: Any]]()
    
    private let fakeSpec = RepoSpec(url: URL(string: "a")!, fullName: "a/a", stars: 0, forks: 0, issues: 0)
        
    override func repoSpec(from dictionary: [String : Any]) -> RepoSpec? {
        self.parsedDictionaries += [dictionary]
        return fakeSpec
    }
    
}
