import Foundation

private let kEnablePublic = false

private let kPublic = kEnablePublic ? "public " : ""
private let kFileStart = """
/// This file is generated using SwiftGodotAssets
import Foundation
import SwiftGodot
import SwiftGodotAssets

"""
private let kEnumStartFormat = kPublic + "enum %@ {"
private let kEnumEnd = "}"
private let kAssetFileFormat = kPublic + "static let %@ = Asset<%@>(path: \"%@\")"
private let kSceneFileFormat = kPublic + "static let %@ = AssetScene<%@>(path: \"%@\")"

final class CodeGenerator {
    private let fileManager: FileManager
    private let outputURL: URL
    private let rootDirectory: Directory
    private let shaderGenerator: ShaderGenerator
    private let assetTypes: [AssetType]

    init(outputURL: URL, rootDirectory: Directory, shaderGenerator: ShaderGenerator,
         assetTypes: [AssetType])
    {
        print("Generating code for \(assetTypes)")
        self.fileManager = FileManager.default
        self.outputURL = outputURL
        self.rootDirectory = rootDirectory
        self.shaderGenerator = shaderGenerator
        self.assetTypes = assetTypes
    }

    func generate() {
        for type in self.assetTypes {
            if type == .shaderMaterial {
                self.createShaderMaterialFile()
            } else {
                self.createFile(for: type)
            }
        }
    }

    // MARK: - Private

    private func createFile(for assetType: AssetType) {
        let fileName = "\(assetType.fileRepresentation).swift"
        print("Create file \(assetType.fileRepresentation)")
        var output = [kFileStart]

        let startDirectory: Directory
        if let skipDirectory = self.rootDirectory.skipToDirectory(for: assetType) {
            startDirectory = skipDirectory
        } else {
            startDirectory = self.rootDirectory
        }

        let definitions = self.definitions(for: startDirectory,
                                           overridedName: assetType.classRepresentation,
                                           assetType: assetType, tabs: 0)
        output.append(contentsOf: definitions)
        
        self.generateFile(data: output, fileName: fileName)
    }

    private func createShaderMaterialFile() {
        let fileName = "ShaderMaterials.swift"
        print("Create file \(fileName)")
        var output = [kFileStart]

        output.append("// MARK: - Accessor code")

        /// Accessing of the shader materials and editrs
        output.append(contentsOf: self.shaderGenerator.accessorCode())

        output.append("// MARK: - Editor Accessor code")

        /// Accessing and editor off an existing shader material
        output.append(contentsOf: self.shaderGenerator.editorAccessorCode())

        output.append("// MARK: - Editor code")

        /// Code for the editors.
        output.append(contentsOf: self.shaderGenerator.editorCode())

        self.generateFile(data: output, fileName: fileName)
    }

    private func definitions(for directory: Directory, overridedName: String? = nil, assetType: AssetType,
                             tabs: Int) -> [String]
    {
        guard directory.recursivelyContains(of: assetType) else {
            return []
        }

        var output = [self.tab(tabs) + String(format: kEnumStartFormat, overridedName ?? directory.name)]
        for file in directory.files(of: assetType).sorted({ $0.name < $1.name }) {
            let assetString: String
            if assetType.isScene {
                assetString = String(format: kSceneFileFormat,
                                     file.name.variableNameString(),
                                     file.typeString,
                                     file.godotPath)
            } else {
                assetString = String(format: kAssetFileFormat,
                                     file.name.variableNameString(),
                                     file.typeString,
                                     file.godotPath)
            }

            output.append(self.tab(tabs + 1) + assetString)
        }

        /// Recursively search child directories
        for childDirectory in directory.directories {
            let directoryOutput = self.definitions(for: childDirectory, assetType: assetType,
                                                   tabs: tabs + 1)
            output.append(contentsOf: directoryOutput)
        }

        output.append(self.tab(tabs) + kEnumEnd)

        return output
    }
    
    private func tab(_ tab: Int) -> String {
        var output = [String]()
        for _ in 0..<tab {
            output.append("    ")
        }
        
        return output.joined(separator: "")
    }
    
    private func generateFile(data: [String], fileName: String) {
        print("Saving file")
        let fileURL = self.outputURL.appendingPathComponent(fileName)
        let dataToSave = data.joined(separator: "\n")
        do {
            try self.fileManager.createDirectory(at: self.outputURL, withIntermediateDirectories: true)
            try dataToSave.write(to: fileURL, atomically: false, encoding: .utf8)
        } catch let error {
            print("Error \(error)")
        }
    }
}

