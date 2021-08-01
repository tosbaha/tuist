import XCTest
@testable import ProjectAutomation

class TaskTests: XCTestCase {
    func test_errorThrownFromTaskIsHandled() {
        var exitCode: Int32?
        _ = Task(options: [], arguments: ["--tuist-task", "exec", "task_name"], exitHandler: { exitCode = $0 }) { _ in
            throw NSError(domain: #file, code: #line, userInfo: nil)
        }
        XCTAssertEqual(exitCode, EXIT_FAILURE)
    }
}
