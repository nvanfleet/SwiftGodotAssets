import Foundation

enum FileType {
    case directory
    case resource(String)
    case unhandled
    
    var isDirectory: Bool {
        switch self {
        case .directory:
            return true
        default:
            return false
        }
    }
}

private let kIgnoreDirectories = ["build", "bin", "addons"]
private let kResourceLookUp: [String: String] = [
    "jpg": "Image",
    "jpeg": "Image",
    "gif": "Image",
    "png": "Image",
    "glb": "Mesh",
    "obj": "Mesh",
    "tscn": "PackedScene",
    "scn": "PackedScene",
    "gd": "Script",
    "gdshader": "Shader",
    "tres": "Resource",
]

/// Finds all files from the given root directory
final class FileSystemReader {
    private let fileManager: FileManager
    private let fileStore: FileStore
    private let root: URL
    /// Performs the search for all files within the filesystem
    func searchFilesFromRoot() -> Directory {
        self.recursiveSearch(from: self.root)
        
        return self.fileStore.rootDirectory
    }
    
    init?(rootPath: String) {
        self.fileManager = FileManager.default
        let rootURL = URL(fileURLWithPath: rootPath)
        guard let rootDirectory = Directory(url: rootURL) else {
            return nil
        }
        
        self.root = rootURL
        self.fileStore = FileStore(root: rootDirectory)
    }
    
    // MARK: -  Private
    
    private func recursiveSearch(from url: URL) {
        let fileType = self.fileType(for: url)
        switch fileType {
        case .resource:
            self.addFile(url: url, type: fileType)
            return
        case .unhandled:
            return
        case .directory:
            break
        }
        
        do {
            // Avoid invisible folders or ignored folder
            guard let lastComponent = url.pathComponents.last,
                    lastComponent.hasPrefix(".") == false, kIgnoreDirectories.contains(lastComponent) else
            {
                return
            }
            
            // Ignore a directory that contains a .gdignore file
            let contents = try self.fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [])
            guard contents.first(where: { $0.path.hasSuffix(".gdignore") }) != nil else {
                return
            }
            
            for file in contents  {
                self.recursiveSearch(from: file)
            }
        } catch let error {
            print("Error \(error)")
        }
    }
    
    private func fileType(for url: URL) -> FileType {
        var isDirectory: ObjCBool = false
        self.fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory)
        if isDirectory.boolValue {
            return .directory
        }
        
        let fileExtension = url.pathExtension
        guard let fileType = kResourceLookUp[fileExtension] else {
            return .unhandled
        }
        
        return .resource(fileType)
    }
    
    private func addFile(url: URL, type: FileType) {
        self.fileStore.add(url: url, type: type)
    }
}
