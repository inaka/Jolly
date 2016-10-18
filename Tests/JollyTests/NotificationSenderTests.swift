import XCTest
@testable import Jolly

class NotificationSenderTests: XCTestCase {
    
    var sender: NotificationSender!
    var session: FakeURLSession!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        session = FakeURLSession()
        sender = try? NotificationSender(path: "localhost", urlSession: session)
        XCTAssertNotNil(sender)
    }
    
    func testGoodPathConstructor() {
        guard let _ = try? NotificationSender(path: "good_guy_path") else {
            XCTFail("Sender should have been built"); return
        }
    }
    
    func testBadPathConstructor() {
        if let _ = try? NotificationSender(path: "sçumbag_path") {
            XCTFail("Sender should not have been built")
        }
    }
    
    func testURLRequestHTTPMethod() {
        let notification = Notification(message: Notification.Message("test"))
        sender.send(notification).start() { _ in }
        let request = session.request
        XCTAssertNotNil(request)
        XCTAssertEqual(request!.httpMethod, "POST")
    }

    func testURLRequestHeaderFields() {
        let notification = Notification(message: Notification.Message("test"))
        sender.send(notification).start() { _ in }
        let request = session.request
        XCTAssertNotNil(request)
        XCTAssertEqual(request!.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }
    
    func testURLRequestPath() {
        let notification = Notification(message: Notification.Message("test"))
        sender.send(notification).start() { _ in }
        let url = session.request?.url
        XCTAssertNotNil(url)
        XCTAssertEqual(url!.absoluteString, "localhost")
    }
    
    func testURLRequestBodyData() {
        let notification = Notification(message: Notification.Message("test"), color: .green, shouldNotify: true)
        sender.send(notification).start() { _ in }
        let request = session.request
        XCTAssertNotNil(request)
        let data = request!.httpBody
        XCTAssertNotNil(data)
        let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)
        XCTAssertNotNil(json)
        let dict = json as? [String: Any]
        XCTAssertNotNil(dict)
        let from = dict!["from"] as? String
        let color = dict!["color"] as? String
        let message = dict!["message"] as? String
        let format = dict!["message_format"] as? String
        let notify = dict!["notify"] as? Bool
        XCTAssertNotNil(from)
        XCTAssertNotNil(color)
        XCTAssertNotNil(message)
        XCTAssertNotNil(format)
        XCTAssertNotNil(notify)
        XCTAssertEqual(from, "Jolly")
        XCTAssertEqual(color, "green")
        XCTAssertEqual(message, "test")
        XCTAssertEqual(format, "html")
        XCTAssertEqual(notify, true)
    }
    
    func testSuccessfulResponse() {
        let session = FakeURLSession()
        session.data = Data()
        session.urlResponse = URLResponse()
        session.error = nil
        sender = try? NotificationSender(path: "localhost", urlSession: session)
        XCTAssertNotNil(sender)
        let notification = Notification(message: Notification.Message("test"))
        let future = sender.send(notification)
        let expectation = self.expectation(description: "Expected .success")
        future.start() { result in
            guard case .success = result else { XCTFail(); return }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testResponseWithError() {
        let session = FakeURLSession()
        session.data = nil
        session.urlResponse = nil
        session.error = NotificationSender.Error.responseError
        sender = try? NotificationSender(path: "localhost", urlSession: session)
        XCTAssertNotNil(sender)
        let notification = Notification(message: Notification.Message("test"))
        let future = sender.send(notification)
        let expectation = self.expectation(description: "Expected .failure with .responseError")
        future.start() { result in
            guard
            case .failure(let error) = result,
            case .responseError = error
            else { XCTFail(); return }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
}

typealias DataTaskCompletion = ((Data?, URLResponse?, Error?) -> ())

class FakeURLSession: URLSession {
    
    var data: Data?
    var urlResponse: URLResponse?
    var error: Error?
    var request: URLRequest?
    
    init(completion: DataTaskCompletion? = nil) {
        self.completion = completion
    }
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTask {
        self.request = request
        if self.completion == nil {
            self.completion = completionHandler
        }
        return FakeURLSessionDataTask(session: self)
    }
    
    fileprivate var completion: DataTaskCompletion?
    fileprivate func executeCompletion() {
        self.completion?(self.data, self.urlResponse, self.error)
    }
    
}

class FakeURLSessionDataTask: URLSessionDataTask {
    
    fileprivate let session: FakeURLSession
    
    init(session: FakeURLSession) {
        self.session = session
    }
    
    override func resume() {
        self.session.executeCompletion()
    }
    
}
