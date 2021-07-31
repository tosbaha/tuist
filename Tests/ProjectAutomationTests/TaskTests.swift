import XCTest
@testable import ProjectAutomation

class TaskTests: XCTestCase {
    func test_errorThrownFromTaskIsHandled() {
        _ = Task { _ in
            throw NSError(domain: #file, code: #line, userInfo: nil)
        }
    }
}
