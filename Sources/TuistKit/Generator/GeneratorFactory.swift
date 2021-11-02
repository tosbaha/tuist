import Foundation
import TuistGraph
import TuistCache
import TuistGenerator
import TuistLoader
import TSCBasic
import TuistSupport
import TuistCore

/// The protocol describes the interface of a factory that instantiates
/// generators for different commands
protocol GeneratorFactorying {
    
    /// Returns the generator for focused projects.
    /// - Parameter config: The project configuration.
    /// - Parameter sources: The list of targets whose sources should be inclued.
    /// - Parameter xcframeworks: Whether targets should be cached as xcframeworks.
    /// - Parameter cacheProfile: The caching profile.
    /// - Parameter ignoreCache: True to not include binaries from the cache.
    /// - Returns: The generator for focused projects.
    func focus(config: Config,
               sources: Set<String>,
               xcframeworks: Bool,
               cacheProfile: TuistGraph.Cache.Profile,
               ignoreCache: Bool) -> Generating
    
    /// Returns the generator to generate a project to run tests on.
    /// - Parameter config: The project configuration
    /// - Parameter automationPath: The automation path.
    /// - Parameter testsCacheDirectory: The cache directory used for tests.
    /// - Parameter skipUITests: Whether UI tests should be skipped.
    /// - Returns: A Generator instance.
    func test(
        config: Config,
        automationPath: AbsolutePath,
        testsCacheDirectory: AbsolutePath,
        skipUITests: Bool
    ) -> Generating
    
    /// Returns the default generator.
    /// - Parameter config: The project configuration.
    /// - Returns: A Generator instance.
    func `default`(config: Config) -> Generating
    
    /// Returns a generator that generates a cacheable project.
    /// - Parameter config: The project configuration.
    /// - Parameter includedTargets: The targets to cache. When nil, it caches all the cacheable targets.
    /// - Returns: A Generator instance.
    func cache(config: Config, includedTargets: Set<String>?) -> Generating
}

class GeneratorFactory: GeneratorFactorying {
    
    let graphMapperFactory: GraphMapperFactorying
    let workspaceMapperFactory: WorkspaceMapperFactorying
    
    convenience init(contentHasher: ContentHashing = ContentHasher()) {
        let workspaceMapperFactory = WorkspaceMapperFactory(contentHasher: contentHasher)
        let graphMapperFactory = GraphMapperFactory(contentHasher: contentHasher)
        self.init(graphMapperFactory: graphMapperFactory,
                  workspaceMapperFactory: workspaceMapperFactory)
    }
    
    init(graphMapperFactory: GraphMapperFactorying,
         workspaceMapperFactory: WorkspaceMapperFactorying) {
        self.graphMapperFactory = graphMapperFactory
        self.workspaceMapperFactory = workspaceMapperFactory
    }
    
    func focus(config: Config,
               sources: Set<String>,
               xcframeworks: Bool,
               cacheProfile: TuistGraph.Cache.Profile,
               ignoreCache: Bool) -> Generating {
        let contentHasher = ContentHasher()
        let graphMapper = graphMapperFactory.focus(config: config,
                                                   cache: !ignoreCache,
                                                   cacheSources: sources,
                                                   cacheProfile: cacheProfile,
                                                   cacheOutputType: xcframeworks ? .xcframework : .framework)
        let projectMapperProvider = ProjectMapperProvider(contentHasher: contentHasher)
        let workspaceMapper = workspaceMapperFactory.default(config: config)
        return Generator(
            projectMapperProvider: projectMapperProvider,
            graphMapper: graphMapper,
            workspaceMapper: workspaceMapper,
            manifestLoaderFactory: ManifestLoaderFactory()
        )
    }
    
    func `default`(config: Config) -> Generating {
        self.default(config: config, contentHasher: ContentHasher())
    }
    
    func test(
        config: Config,
        automationPath: AbsolutePath,
        testsCacheDirectory: AbsolutePath,
        skipUITests: Bool
    ) -> Generating {
        let graphMapper = graphMapperFactory.automation(config: config, testsCacheDirectory: testsCacheDirectory)
        let workspaceMapper = workspaceMapperFactory.automation(config: config,
                                                                workspaceDirectory: FileHandler.shared.resolveSymlinks(automationPath))

        return Generator(
            projectMapperProvider: AutomationProjectMapperProvider(skipUITests: skipUITests),
            graphMapper: graphMapper,
            workspaceMapper: workspaceMapper,
            manifestLoaderFactory: ManifestLoaderFactory()
        )
    }
    
    func cache(config: Config, includedTargets: Set<String>?) -> Generating {
        let contentHasher = CacheContentHasher()
        let projectMapperProvider = CacheControllerProjectMapperProvider(contentHasher: contentHasher)
        let graphMapper = self.graphMapperFactory.cache(includedTargets: includedTargets)
        let workspaceMapper = self.workspaceMapperFactory.cache(config: config, includedTargets: includedTargets ?? [])
        return Generator(
            projectMapperProvider: projectMapperProvider,
            graphMapper: graphMapper,
            workspaceMapper: workspaceMapper,
            manifestLoaderFactory: ManifestLoaderFactory()
        )
    }
    
    // MARK: - Fileprivate
    
    func `default`(config: Config, contentHasher: ContentHashing) -> Generating {
        let projectMapperProvider = ProjectMapperProvider(contentHasher: contentHasher)
        let graphMapper = graphMapperFactory.default()
        let workspaceMapper = workspaceMapperFactory.default(config: config)
        return Generator(
            projectMapperProvider: projectMapperProvider,
            graphMapper: graphMapper,
            workspaceMapper: workspaceMapper,
            manifestLoaderFactory: ManifestLoaderFactory()
        )
    }
}
