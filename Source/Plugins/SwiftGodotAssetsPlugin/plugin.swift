import Foundation
import PackagePlugin

/// Generates the code representing existing Godot assets.
@main struct SwiftCodeGeneratorPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        // We only generate commands for source targets.
        let generator: Path = try context.tool(named: "AssetGenerator").path
        let scanningDirectory = context.package.directory
        let genSourcesDir = context.pluginWorkDirectory.appending("GeneratedSources")
        let arguments: [CustomStringConvertible] = [ scanningDirectory, genSourcesDir ]
        let outputFiles: [Path] = known.map { genSourcesDir.appending([$0]) }
        let cmd: Command = Command.buildCommand(
            displayName: "Generating SwiftAssets to \(genSourcesDir)",
            executable: generator,
            arguments: arguments,
            inputFiles: [scanningDirectory],
            outputFiles: outputFiles)
        return [cmd]
    }
}

let known = [
    "Assets.swift",
]
