import Foundation

public struct Task {
    public let options: [Option]
    public let task: ([String: String]) throws -> Void

    public enum Option: Equatable {
        case option(String)
    }

    public init(
        options: [Option] = [],
        task: @escaping ([String: String]) throws -> Void
    ) {
        self.init(
            options: options,
            arguments: CommandLine.arguments,
            exitHandler: { exit($0) }, // wrap true exit handler to convert (Int32) -> Never to (Int32) -> Void
            task: task
        )
    }

    init(
        options: [Option],
        arguments: [String],
        exitHandler: (Int32) -> Void,
        task: @escaping ([String: String]) throws -> Void
    ) {
        self.options = options
        self.task = task

        runIfNeeded(arguments: arguments, exitHandler: exitHandler)
    }

    private func runIfNeeded(arguments: [String], exitHandler: (Int32) -> Void) {
        guard
            let taskCommandLineIndex = arguments.firstIndex(of: "--tuist-task"),
            arguments.count > taskCommandLineIndex
        else { return }
        let attributesString = arguments[taskCommandLineIndex + 1]

        do {
            let attributes: [String: String] = try JSONDecoder().decode(
                [String: String].self,
                from: attributesString.data(using: .utf8)!
            )
            try task(attributes)
            exitHandler(EXIT_SUCCESS)
        } catch {
            print("Unexpected error running task: \(String(describing: error))")
            exitHandler(EXIT_FAILURE)
        }
    }
}
