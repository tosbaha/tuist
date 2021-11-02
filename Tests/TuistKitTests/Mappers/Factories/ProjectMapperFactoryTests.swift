import Foundation
import TSCBasic
import TuistCore
import TuistCoreTesting
import TuistGraph
import XCTest
@testable import TuistGenerator
import TuistLoader
import TuistSigning
import TuistAutomation
@testable import TuistCore
@testable import TuistKit
@testable import TuistSupportTesting

final class ProjectMapperFactoryTests: TuistUnitTestCase {
    var subject: ProjectMapperFactory!
    
    override func setUp() {
        super.setUp()
        subject = ProjectMapperFactory()
    }
    
    override func tearDown() {
        subject = nil
        super.tearDown()
    }
    
    func test_default_when_synthesizing_of_resource_interfaces_is_disabled() {
        // Given
        let config = Config.test(generationOptions: [])
        
        // When
        let got = subject.default(config: config)
        
        // Then
        
        XCTAssertContainsElementOfType(got, SynthesizedResourceInterfaceProjectMapper.self)
        
    }
    
    func test_default_when_synthesizing_of_resource_interfaces_is_enabled() {
        // Given
        let config = Config.test(generationOptions: [
            .disableSynthesizedResourceAccessors
        ])
        
        // When
        let got = subject.default(config: config)
        
        // Then
        
        XCTAssertDoesntContainElementOfType(got, SynthesizedResourceInterfaceProjectMapper.self)
        
    }
    
    func test_default_when_showing_env_variables_in_scripts_is_disabled() {
        // Given
        let config = Config.test(generationOptions: [
            .disableShowEnvironmentVarsInScriptPhases
        ])
        
        // When
        let got = subject.default(config: config)
        
        // Then
        
        XCTAssertContainsElementOfType(got, TargetProjectMapper.self)
        
    }
    
    func test_default_when_showing_env_variables_in_scripts_is_enabled() {
        // Given
        let config = Config.test(generationOptions: [
        ])
        
        // When
        let got = subject.default(config: config)
        
        // Then
        
        XCTAssertDoesntContainElementOfType(got, TargetProjectMapper.self)
        
    }
    
    func test_default_when_bundle_accessors_are_enabled() {
        // Given
        let config = Config.test(generationOptions: [
        ])
        
        // When
        let got = subject.default(config: config)
        
        // Then
        
        XCTAssertContainsElementOfType(got, ResourcesProjectMapper.self)
        XCTAssertContainsElementOfType(got, ResourcesProjectMapper.self, after: DeleteDerivedDirectoryProjectMapper.self)
        
    }
    
    func test_default_when_bundle_accessors_are_disabled() {
        // Given
        let config = Config.test(generationOptions: [
            .disableBundleAccessors
        ])
        
        // When
        let got = subject.default(config: config)
        
        // Then
        
        XCTAssertDoesntContainElementOfType(got, ResourcesProjectMapper.self)
    }
    
    func test_default_when_autogenerated_schemes_is_enabled() {
        // Given
        let config = Config.test(generationOptions: [
        ])
        
        // When
        let got = subject.default(config: config)
        
        // Then
        
        XCTAssertContainsElementOfType(got, AutogeneratedSchemesProjectMapper.self)
    }
    
    func test_default_when_autogenerated_schemes_is_disabled() {
        // Given
        let config = Config.test(generationOptions: [
            .disableAutogeneratedSchemes
        ])
        
        // When
        let got = subject.default(config: config)
        
        // Then
        XCTAssertDoesntContainElementOfType(got, AutogeneratedSchemesProjectMapper.self)
    }
    
    func test_default_contains_the_generate_info_plist_mapper() {
        // Given
        let config = Config.test(generationOptions: [
        ])
        
        // When
        let got = subject.default(config: config)
        
        // Then
        XCTAssertContainsElementOfType(got, GenerateInfoPlistProjectMapper.self, after: DeleteDerivedDirectoryProjectMapper.self)
    }
    
    func test_default_contains_the_project_name_and_organization_mapper() {
        // Given
        let config = Config.test(generationOptions: [
        ])
        
        // When
        let got = subject.default(config: config)
        
        // Then
        XCTAssertContainsElementOfType(got, ProjectNameAndOrganizationMapper.self)
    }
    
    func test_default_contains_the_project_development_region_mapper() {
        // Given
        let config = Config.test(generationOptions: [
        ])
        
        // When
        let got = subject.default(config: config)
        
        // Then
        XCTAssertContainsElementOfType(got, ProjectDevelopmentRegionMapper.self)
    }
    
    func test_default_contains_the_ide_template_macros_mapper() {
        // Given
        let config = Config.test(generationOptions: [
        ])
        
        // When
        let got = subject.default(config: config)
        
        // Then
        XCTAssertContainsElementOfType(got, IDETemplateMacrosMapper.self)
    }
    
    func test_default_contains_the_signing_mapper() {
        // Given
        let config = Config.test(generationOptions: [
        ])
        
        // When
        let got = subject.default(config: config)
        
        // Then
        XCTAssertContainsElementOfType(got, SigningMapper.self)
    }
    
    func test_automation_contains_the_source_root_path_project_mapper() {
        // Given
        let config = Config.test(generationOptions: [
        ])
        
        // When
        let got = subject.automation(config: config, skipUITests: true)
        
        // Then
        XCTAssertContainsElementOfType(got, SourceRootPathProjectMapper.self)
    }
    
    func test_automation_contains_the_skip_ui_tests_mapper_when_skip_ui_tests_is_true() {
        // Given
        let config = Config.test(generationOptions: [
        ])
        
        // When
        let got = subject.automation(config: config, skipUITests: true)
        
        // Then
        XCTAssertContainsElementOfType(got, SkipUITestsProjectMapper.self)
    }
    
    func test_automation_doesnt_contain_the_skip_ui_tests_mapper_when_skip_ui_tests_is_false() {
        // Given
        let config = Config.test(generationOptions: [
        ])
        
        // When
        let got = subject.automation(config: config, skipUITests: false)
        
        // Then
        XCTAssertDoesntContainElementOfType(got, SkipUITestsProjectMapper.self)
    }
    
    func test_automation_contains_the_autogenerated_schemes_project_mapper_even_if_autogenerated_schemes_are_disabled_in_the_config() {
        // Given
        let config = Config.test(generationOptions: [
            .disableAutogeneratedSchemes,
            .enableCodeCoverage(.all)
        ])
        
        // When
        let got = subject.automation(config: config, skipUITests: false)
        
        // Then
        let mapper = XCTAssertContainsElementOfType(got, AutogeneratedSchemesProjectMapper.self)
        XCTAssertEqual(mapper?.enableCodeCoverage, true)
    }
}
