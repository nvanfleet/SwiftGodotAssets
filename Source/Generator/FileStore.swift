import Foundation

final class FileStore {
    /// The root directory of the filestore.
    let rootDirectory: Directory

    func add(path: String, isDirectory: Bool, fileExtension: String, assetType: AssetType, typeString: String) 
    {
        let maskedPath = path.replacingOccurrences(of: self.rootDirectory.path, with: "")
        let pathComponents = maskedPath.split(separator: "/").map(String.init)
        let finalIndex = pathComponents.count - 1
        var currentDirectory = self.rootDirectory
        for (index, component) in pathComponents.enumerated() {
            // Add file but escape if it's a directory leave function when done
            let split = component.split(separator: ".")
            if index == finalIndex && isDirectory == false, let name = split.first.map(String.init) {
                let file = File(fullPath: path, godotPath: maskedPath, name: name,
                                fileExtension: fileExtension, assetType: assetType, typeString: typeString,
                                directory: currentDirectory)
                currentDirectory.add(file: file)
                return
            }

            let directory: Directory
            if let existing = currentDirectory.childDirectories[component] {
                directory = existing
            } else {
                directory = Directory(name: component, path: maskedPath, parent: currentDirectory)
                currentDirectory.add(directory: directory)
            }

            currentDirectory = directory
        }
    }
    
    init(root: Directory) {
        self.rootDirectory = root
    }
}
