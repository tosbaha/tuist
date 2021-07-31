import Foundation

public struct Task {
    public let options: [Option]
    public let task: ([String: String]) throws -> Void

    public enum Option: Equatable {
        case option(String)
    }

    @_disfavoredOverload public init(
        options: [Option] = [],
        task: @escaping ([String: String]) throws -> Void
    ) {
        self.init(options: options, task: task)
    }

    init(
        options: [Option] = [],
        arguments: [String] = CommandLine.arguments,
        task: @escaping ([String: String]) throws -> Void
    ) {
        self.options = options
        self.task = task

        runIfNeeded(arguments: arguments)
    }

    private func runIfNeeded(arguments: [String]) {
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
        } catch {
            print("Unexpected error running task: \(String(describing: error))")
        }
    }
}
