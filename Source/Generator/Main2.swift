//import Foundation
//
//@main
//struct SceneGen: ParsableCommand {
//    @Argument(help: "The path to a folder with a project.godot file")
//    var searchPath: String
//
//    @Argument(help: "The location to place the generated code.")
//    var outputPath: String
//
//    @Argument(help: "The location to place the generated code.")
//    var targetedTypes: String
//
//    mutating func run() throws {
//        do {
//            try self.resetOutputFolder(outputPath: outputPath)
//        } catch let error {
//            print("Failed to reset output path")
//        }
//
//        let assetTypes = AssetType.fromDeliminated(string: targetedTypes)
//        let outputURL = URL(fileURLWithPath: outputPath)
//        if let reader = FileSystemReader(rootPath: searchPath, assetTypes: assetTypes) {
//            let rootDirectory = reader.searchFilesFromRoot()
//            let shaderGenerator = ShaderGenerator(rootDirectory: rootDirectory)
//            shaderGenerator.generateAllShaders()
//            print("Done found \(rootDirectory.recursiveFileCount) files")
//            let codeGenerator = CodeGenerator(outputURL: outputURL, rootDirectory: rootDirectory,
//                                              shaderGenerator: shaderGenerator, assetTypes: assetTypes)
//            codeGenerator.generate()
//            print("Asset generation done")
//        }
//    }
//
//    private func resetOutputFolder(outputPath: String) throws {
//        let fileManager = FileManager.default
//        if fileManager.fileExists(atPath: outputPath) {
//            print("Removing existing folder.")
//            try fileManager.removeItem(atPath: outputPath)
//        }
//
//        print("Creating output folder.")
//        try fileManager.createDirectory(atPath: outputPath, withIntermediateDirectories: true,
//                                        attributes: nil)
//    }
//}
