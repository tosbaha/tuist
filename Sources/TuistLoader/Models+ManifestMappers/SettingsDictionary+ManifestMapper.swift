//
//  File.swift
//  
//
//  Created by Harris, David (D.A.) on 10/28/21.
//

import Foundation
import ProjectDescription
import TuistGraph

extension TuistGraph.SettingsDictionary {
    /// Maps a ProjectDescription.DeploymentTarget instance into a TuistGraph.DeploymentTarget instance.
    /// - Parameters:
    ///   - manifest: Manifest representation of deployment target model.
    ///   - generatorPaths: Generator paths.
    static func from(manifest: ProjectDescription.SettingsDictionary) -> TuistGraph.SettingsDictionary {
        return manifest.mapValues { value in
            switch value {
            case .string(let stringValue):
                return TuistGraph.SettingValue.string(stringValue)
            case .array(let arrayValue):
                return TuistGraph.SettingValue.array(arrayValue)
            }
        }
    }
}
