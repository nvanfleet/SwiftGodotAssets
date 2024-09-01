import Foundation
import PackagePlugin

private let kAllAssetTypes = "image,mesh,scene,script,shader,shader_material,resource"
private let kConfigFile = "AssetGeneratorConfiguration.json"

struct Configuration: Codable {
    enum CodingKeys: String, CodingKey {
        case assetPath = "asset_path"
        case assetTypes = "asset_types"
    }

    /// The path to the scanning directory. Ultimately has to be the root of the Godot project since the
    /// tool has to generate res:// paths that are functional. If you want to omit some data you can either
    /// exclude data types or if they aren't part of your godot project you can adda .gdignore file in
    /// directories you want excluded.
    let assetPath: String
    /// A list of the file types that you wish to be included in asset generation. This is a String
    /// not an array since it has to be passed to the command as a singular command.
    /// options: image,mesh,scene,script,shader,resource
    let assetTypes: String
}

/// Generates the code representing existing Godot assets.
@main struct SwiftCodeGeneratorPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        let rootPath = #file
            .split(separator: "/", omittingEmptySubsequences: false)
            .dropLast(7)
            .map { String($0) }
            .joined(separator: "/")

        let scanningDirectory: Path
        let assetTarget: String
        let outputList: [String]

        let decoder = JSONDecoder()
        if let configurationData = FileManager.default.contents(atPath: rootPath + "/\(kConfigFile)"),
            let configuration = try? decoder.decode(Configuration.self, from: configurationData)
        {
            scanningDirectory = Path(configuration.assetPath)
            assetTarget = configuration.assetTypes
            outputList = self.fileList(for: configuration.assetTypes)
        } else {
            print("No assets path found, using defaults that instead... \(rootPath)")
            scanningDirectory = Path(rootPath)
            assetTarget = kAllAssetTypes
            outputList = self.fileList(for: kAllAssetTypes)
        }

        let generator: Path = try context.tool(named: "AssetGenerator").path
        let genSourcesDir = context.pluginWorkDirectory.appending("GeneratedSources")
        let arguments: [CustomStringConvertible] = [ genSourcesDir, scanningDirectory, assetTarget ]
        let outputFiles: [Path] = outputList.map { genSourcesDir.appending([$0]) }
        let cmd: Command = Command.buildCommand(
            displayName: "Generating SwiftAssets to genSourcesDir: \(genSourcesDir) arguments: \(arguments) outputFiles: \(outputFiles)",
            executable: generator,
            arguments: arguments,
            inputFiles: [scanningDirectory],
            outputFiles: outputFiles)
        return [cmd]
    }

    private func fileList(for arguments: String) -> [String] {
        let split = arguments.split(separator: ",")
        var result = [String]()
        if split.contains("image") {
            result.append("ImageAssets.swift")
        } else if split.contains("mesh") {
            result.append("MeshAssets.swift")
        } else if split.contains("scene") {
            result.append("SceneAssets.swift")
        } else if split.contains("script") {
            result.append("ScriptAssets.swift")
        } else if split.contains("shader") {
            result.append("ShaderAssets.swift")
        } else if split.contains("resource") {
            result.append("ResourceAssets.swift")
        } else if split.contains("shader_material") {
            result.append("ShaderMaterials.swift")
        }

        return result
    }
}
