import Foundation

enum FileType {
    case directory
    case resource(_ type: AssetType, _ typeString: String, _ fileExtension: String)
    case unhandled
}

extension FileType: Equatable {
    static func == (lhs: FileType, rhs: FileType) -> Bool {
        switch (lhs, rhs) {
        case (.directory, .directory):
            return true
        case (.unhandled, .unhandled):
            return true
        case (.resource(let lhsType, let lhsTString, let lhsExtension),
            .resource(let rhsType, let rhsTString, let rhsExtension)):
            return lhsType == rhsType && lhsTString == rhsTString && lhsExtension == rhsExtension
        default:
            return false
        }
    }
}

private let kIgnoreDirectories = ["build", "bin", "addons"]

/// Finds all files from the given root directory
final class FileSystemReader {
    private let fileManager: FileManager
    private let fileStore: FileStore
    private let rootPath: String
    private let assetTypes: [AssetType]

    /// Performs the search for all files within the filesystem
    func searchFilesFromRoot() -> Directory {
        self.recursiveSearch(from: self.rootPath)
        return self.fileStore.rootDirectory
    }
    
    init?(rootPath: String, assetTypes: [AssetType]) {
        self.fileManager = FileManager.default
        self.assetTypes = assetTypes
        guard let rootDirectory = Directory(path: rootPath) else {
            return nil
        }
        
        self.rootPath = rootPath
        self.fileStore = FileStore(root: rootDirectory)
    }
    
    // MARK: -  Private
    
    private func recursiveSearch(from path: String) {
        switch self.fileType(for: path) {
        case .resource(let type, let typeString, let fileExtension):
            self.fileStore.add(path: path, isDirectory: false, fileExtension: fileExtension,
                               assetType: type, typeString: typeString)
        case .unhandled:
            return
        case .directory:
            self.searchDirectory(at: path)
        }
    }

    private func searchDirectory(at path: String) {
        let components = path.split(separator: "/")

        do {
            // Avoid invisible folders or ignored folder
            guard let lastComponent = components.last.map(String.init),
                  lastComponent.hasPrefix(".") == false,
                  kIgnoreDirectories.contains(lastComponent) == false else
            {
                return
            }

            // Ignore a directory that contains a .gdignore file since those would not be usable.
            let contents = try self.fileManager.contentsOfDirectory(atPath: path)
            guard contents.first(where: { $0 == ".gdignore" }) == nil else {
                return
            }

            for file in contents {
                self.recursiveSearch(from: "\(path)/\(file)")
            }
        } catch let error {
            print("Error: \(error)")
        }
    }

    private func fileType(for path: String) -> FileType {
        var isDirectory: ObjCBool = false
        let fileExists = self.fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
        guard fileExists else {
            print("File does not exist at \(path)")
            return .unhandled
        }

        if isDirectory.boolValue {
            return .directory
        }
        
        guard let fileExtension = path.split(separator: ".").last.map(String.init) else {
            return .unhandled
        }

        if let details = AssetType.details(for: fileExtension, at: path) {
            return .resource(details.assetType, details.typeString, fileExtension)
        }

        return .unhandled
    }
}
