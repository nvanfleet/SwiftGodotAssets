import Foundation

final class FileStore {
    /// The root directory of the filestore.
    let rootDirectory: Directory
    
    func add(url: URL, type: FileType) {
        let pathComponents = url.pathComponents
        let isDirectory = type.isDirectory
        let finalIndex = pathComponents.count - 1
        var currentDirectory = self.rootDirectory
        var currentIndex = self.rootDirectory.componentCount
        while currentIndex < pathComponents.count {
            let name = pathComponents[currentIndex]
            
            // Add file but escape if it's a directory
            if currentIndex == finalIndex && !isDirectory {
                let fileExtension = url.pathExtension
                let file = File(url: url, name: name, fileExtension: fileExtension, type: type)
                currentDirectory.add(file: file)
                break
            }
            
            let directory: Directory
            if let existing = currentDirectory.childDirectories[name] {
                directory = existing
            } else {
                directory = Directory(name: name, componentCount: currentIndex + 1)
                currentDirectory.add(directory: directory)
            }
            
            currentDirectory = directory
            currentIndex += 1
        }
    }
    
    init(root: Directory) {
        self.rootDirectory = root
    }
}
