import Foundation

private let kFileStart = """
/// This file is generated using SwiftGodotAssets
import Foundation
import SwiftGodot

"""
private let kEnumStartFormat = "public enum %@ {"
private let kEnumEnd = "}"

private let kBaseDeclaration = "public extension Assets {"
private let kFileFormat = "public static let %@ = %@<%@>(path: \"%@\")"
private let kAsset = "Asset"
private let kAssetScene = "AssetScene"

final class CodeGenerator {
    private let fileManager: FileManager
    private let outputURL: URL
    private let rootDirectory: Directory
    private let assetTypes: [AssetType]

    init(outputURL: URL, rootDirectory: Directory, assetTypes: [AssetType]) {
        print("Generating code for \(assetTypes)")
        self.fileManager = FileManager.default
        self.outputURL = outputURL
        self.rootDirectory = rootDirectory
        self.assetTypes = assetTypes
    }

    func generate() {
        for type in self.assetTypes {
            self.createFile(for: type)
        }
    }

    // MARK: - Private

    private func createFile(for assetType: AssetType) {
        let fileName = "\(assetType.fileRepresentation).swift"
        print("Create file \(assetType.fileRepresentation)")
        var output = [kFileStart]
        let definitions = self.definitions(for: self.rootDirectory,
                                           overridedName: assetType.classRepresentation,
                                           assetType: assetType, tabs: 0)
        output.append(contentsOf: definitions)
        self.generateFile(data: output, fileName: fileName)
    }

    private func definitions(for directory: Directory, overridedName: String? = nil, assetType: AssetType,
                             tabs: Int) -> [String]
    {
        guard directory.recursivelyContains(of: assetType) else {
            return []
        }
        
        var output = [self.tab(tabs) + String(format: kEnumStartFormat, overridedName ?? directory.name)]
        for file in directory.files(of: assetType) {
            let assetString: String
            if assetType.isScene {
                assetString = kAssetScene
            } else {
                assetString = kAsset
            }

            let fileString = String(format: kFileFormat, 
                                    file.name.variableNameString(),
                                    assetString,
                                    file.typeString,
                                    file.godotPath)
            output.append(self.tab(tabs + 1) + fileString)
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

