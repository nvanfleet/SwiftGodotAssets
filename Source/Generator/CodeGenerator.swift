import Foundation

private let kFileStart = """
import Foundation
import SwiftGodot

"""
private let kExtensionStart = "public extension Assets {"
private let kEnumStartFormat = "public enum %s {"
private let kEnumEnd = "}"
private let kFileFormat = "static let %s = Asset<%s>(path: %s)"

final class CodeGenerator {
    private let fileManager: FileManager
    private let output: URL
    private let rootDirectory: Directory
    
    init(output: URL, rootDirectory: Directory) {
        self.fileManager = FileManager.default
        self.output = output
        self.rootDirectory = rootDirectory
    }
    
    func generate() {
        self.createFile(directory: self.rootDirectory, name: "Assets")
//        for directory in self.rootDirectory.directories where directory.recursivelyContainsResources {
//            self.createFile(directory: directory, name: directory.name)
//        }
    }
    
    // MARK: - Private
    
    private func createFile(directory: Directory, name: String) {
        guard directory.hasFiles else {
            return
        }
        
        let fileName = "\(name).swift"
        var output = [kFileStart, kExtensionStart]
        output.append(contentsOf: self.createSection(for: directory, tabLevel: 0))
        output.append(kEnumEnd)
        
        self.generateFile(data: output, fileName: fileName)
    }
    
    private func createSection(for directory: Directory, tabLevel: Int) -> [String] {
        var output = [kFileStart]
        let tabLevel = 0
        
        output.append(self.tab(tabLevel) + String(format: kEnumStartFormat, directory.name))
        for file in directory.files {
            let fileString = String(format: kFileFormat, file.name, file.typeString, file.url.absoluteString)
            output.append(self.tab(tabLevel + 1) + fileString)
        }
        output.append(self.tab(tabLevel) + kEnumEnd)
        
        for subDirectory in directory.directories where subDirectory.recursivelyContainsResources {
            output.append(contentsOf: self.createSection(for: subDirectory, tabLevel: tabLevel + 1))
        }
        
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
        let fileURL = self.output.appendingPathComponent(fileName)
        let dataToSave = data.joined(separator: "")
        do {
            try self.fileManager.createDirectory(at: self.output, withIntermediateDirectories: true)
            self.fileManager.createFile(atPath: fileURL.path, contents: dataToSave.data(using: .utf8))
        } catch let error {
            print("Error \(error)")
        }
    }
}
