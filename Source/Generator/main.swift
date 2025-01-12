import Foundation

var args = CommandLine.arguments

/// /Users/nvanfleet/src/PlantQuest/build/plugins/outputs/swiftgodotassets/SwiftGodotAssets/SwiftGodotAssetsPlugin/GeneratedSources
let generatorOutput = args.count > 1 ? args[1] : ""

/// /Users/nvanfleet/src/PlantQuest
let assetDirectory = args.count > 2 ? args[2] : ""

/// image,mesh,scene,script,shader,shader_material,resource
let targetedTypes = args.count > 3 ? args[3] : "image,mesh,scene,script,shader,shader_material,resource"

print("Hello")

if args.count < 4 {
    print("Usage is: generator path-to-files output-directory")
    print("- path-to-files is the full path to extension_api.json from Godot")
    print("- output-directory is where the files will be placed")
    print("- target-types is what type of files are looked for")
}

do {
    try resetOutputFolder(outputPath: generatorOutput)
} catch let error {
    print("Error \(error)")
}

print("Processing directory: \(assetDirectory) to: \(generatorOutput) targets: \(targetedTypes)")

let assetTypes = AssetType.fromDeliminated(string: targetedTypes)
let outputURL = URL(fileURLWithPath: generatorOutput)
if let reader = FileSystemReader(rootPath: assetDirectory, assetTypes: assetTypes) {
    let rootDirectory = reader.searchFilesFromRoot()
    let shaderGenerator = ShaderGenerator(rootDirectory: rootDirectory)
    shaderGenerator.generateAllShaders()
    print("Done found \(rootDirectory.recursiveFileCount) files")
    let codeGenerator = CodeGenerator(outputURL: outputURL, rootDirectory: rootDirectory,
                                      shaderGenerator: shaderGenerator, assetTypes: assetTypes)
    codeGenerator.generate()
    print("Asset generation done")
}

private func resetOutputFolder(outputPath: String) throws {
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: outputPath) {
        print("Removing existing folder.")
        try fileManager.removeItem(atPath: outputPath)
    }

    print("Creating output folder.")
    try fileManager.createDirectory(atPath: outputPath, withIntermediateDirectories: true,
                                    attributes: nil)
}
