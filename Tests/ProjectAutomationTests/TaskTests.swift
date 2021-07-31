import ProjectAutomation
import XCTest

class TaskTests: XCTestCase {
    override class func setUp() {
        super.setUp()

        CommandLine.arguments = ["--tuist-task", "exec", "task_name"]
    }

    override func tearDown() {
        super.tearDown()

        CommandLine.arguments = []
    }

    func test_errorThrownFromTaskIsHandled() {
        _ = Task { _ in
            throw NSError(domain: #file, code: #line, userInfo: nil)
        }
    }
}
