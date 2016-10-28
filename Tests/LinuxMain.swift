import XCTest
@testable import JollyTests
 
XCTMain([
    testCase(CacheTests.allTests),
    testCase(CommandRouterTests.allTests),
    testCase(NotificationSenderTests.allTests),
    testCase(RepoSpecParserTests.allTests),
    testCase(RepoSpecProviderTests.allTests),
    testCase(RepoTests.allTests),
])
