import XCTest
@testable import ProjectAutomation

class TaskTests: XCTestCase {
    func test_errorThrownFromTaskIsHandled() {
        _ = Task(arguments: ["--tuist-task", "exec", "task_name"]) { _ in
            throw NSError(domain: #file, code: #line, userInfo: nil)
        }
    }
}
