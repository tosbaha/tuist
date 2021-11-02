import Foundation
import TuistCore
import TuistGraph
import TuistSupport

/// `GenerateCacheableSchemesWorkspaceMapper` will generate additional schemes which include the targets to be cached
final class GenerateCacheableSchemesWorkspaceMapper: WorkspaceMapping {
    let includedTargets: Set<String>

    init(includedTargets: Set<String>) {
        self.includedTargets = includedTargets
    }

    func map(workspace: WorkspaceWithProjects) throws -> (WorkspaceWithProjects, [SideEffectDescriptor]) {
        let schemes: [Scheme] = Platform.allCases.flatMap { platform in
            scheme(
                platform: platform,
                workspace: workspace
            )
        }

        var workspace = workspace
        workspace.workspace.schemes.append(contentsOf: schemes)
        return (workspace, [])
    }

    // MARK: - Helpers

    private func scheme(
        platform: Platform,
        workspace: WorkspaceWithProjects
    ) -> [Scheme] {
        let projectsWithTargets = workspace
            .projects
            .flatMap { project in project.targets.map { (project, $0) } }
            .filter { $0.1.platform == platform }
            .filter { _, target in includedTargets.contains(target.name) }

        let bundleTargets = projectsWithTargets
            .filter { $0.1.product == .bundle }

        let binariesTargets = projectsWithTargets
            .filter { $0.1.product.isFramework }

        let bundleTargetReferences = bundleTargets
            .map { TargetReference(projectPath: $0.0.path, name: $0.1.name) }
            .sorted(by: { $0.name < $1.name })
        let binariesTargetReferences = binariesTargets
            .map { TargetReference(projectPath: $0.0.path, name: $0.1.name) }
            .sorted(by: { $0.name < $1.name })

        return [
            Scheme(
                name: "\(Constants.AutogeneratedScheme.bundlesSchemeNamePrefix)-\(platform.caseValue)",
                shared: true,
                buildAction: BuildAction(targets: bundleTargetReferences)
            ),
            Scheme(
                name: "\(Constants.AutogeneratedScheme.binariesSchemeNamePrefix)-\(platform.caseValue)",
                shared: true,
                buildAction: BuildAction(targets: binariesTargetReferences)
            ),
        ]
    }
}
