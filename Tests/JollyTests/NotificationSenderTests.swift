import XCTest
@testable import Jolly

#if os(Linux)
    extension NotificationSenderTests {
        static var allTests: [(String, (CacheTests) -> () throws -> Void)] {
            return [
                ("testURLRequestHTTPMethod", testURLRequestHTTPMethod),
                ("testURLRequestHeaderFields", testURLRequestHeaderFields),
                ("testURLRequestPath", testURLRequestPath),
                ("testURLRequestBodyData", testURLRequestBodyData),
                ("testSuccessfulResponse", testSuccessfulResponse),
                ("testResponseWithError", testResponseWithError)
            ]
        }
    }
#endif

class NotificationSenderTests: XCTestCase {
    
    var sender: NotificationSender!
    var session: FakeURLSession!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        session = FakeURLSession()
        sender = NotificationSender(roomId: "1", authenticationToken: "token", urlSession: session)
        XCTAssertNotNil(sender)
    }
    
    func testURLRequestHTTPMethod() {
        let notification = Notification(message: Message("test"))
        sender.send(notification).start() { _ in }
        let request = session.dataTasks.first?.request
        XCTAssertNotNil(request)
        XCTAssertEqual(request!.httpMethod, "POST")
    }

    func testURLRequestHeaderFields() {
        let notification = Notification(message: Message("test"))
        sender.send(notification).start() { _ in }
        let request = session.dataTasks.first?.request
        XCTAssertNotNil(request)
        XCTAssertEqual(request!.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }
    
    func testURLRequestPath() {
        let sender = NotificationSender(roomId: "123", authenticationToken: "asd", urlSession: session)
        let notification = Notification(message: Message("test"))
        sender.send(notification).start() { _ in }
        let url = session.dataTasks.first?.request?.url
        XCTAssertNotNil(url)
        XCTAssertEqual(url!.absoluteString, "https://api.hipchat.com/v2/room/123/notification?auth_token=asd")
    }
    
    func testURLRequestBodyData() {
        let notification = Notification(message: Message("test"), color: .green, shouldNotify: true)
        sender.send(notification).start() { _ in }
        let request = session.dataTasks.first?.request
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
        let params: DataTaskCompletionParameters = (Data(), URLResponse(), nil)
        let session = FakeURLSession(customDataTaskCompletionParameters: params)
        let sender = NotificationSender(roomId: "x", authenticationToken: "x", urlSession: session)
        let notification = Notification(message: Message("test"))
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
        let params: DataTaskCompletionParameters = (nil, nil, NotificationSender.Error.responseError)
        let session = FakeURLSession(customDataTaskCompletionParameters: params)
        let sender = NotificationSender(roomId: "x", authenticationToken: "x", urlSession: session)
        let notification = Notification(message: Message("test"))
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
