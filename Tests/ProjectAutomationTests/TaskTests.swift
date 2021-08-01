import XCTest
@testable import ProjectAutomation

class TaskTests: XCTestCase {
    let arguments: [String] = [#file, "--tuist-task", "{}"]

    func test_errorThrownFromTaskIsHandled() {
        var exitCode: Int32?
        _ = Task(options: [], arguments: arguments, exitHandler: { exitCode = $0 }) { _ in
            throw NSError(domain: #file, code: #line, userInfo: nil)
        }
        XCTAssertEqual(exitCode, EXIT_FAILURE)
    }

    func test_successfulTaskExitsWithSuccessCode() {
        var exitCode: Int32?
        _ = Task(options: [], arguments: arguments, exitHandler: { exitCode = $0 }) { _ in }
        XCTAssertEqual(exitCode, EXIT_SUCCESS)
    }
}
