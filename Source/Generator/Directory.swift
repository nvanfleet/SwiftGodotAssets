import Foundation

class Directory {
    private(set) var childDirectories = [String: Directory]()
    private var childFiles = [String: File]()

    /// The path of the directory.
    let path: String

    /// The name of this directory
    let name: String

    /// The files in this directory
    var files: [File] { self.childFiles.map { $0.value } }
    
    /// The directories in this directory
    var directories: [Directory] { self.childDirectories.map { $0.value } }
    
    /// Whether there are files in this directory
    var hasFiles: Bool { self.files.isEmpty == false }
    
    /// Total count including this file and all child directories
    var recursiveFileCount: Int {
        var count = self.files.count
        for childDirectory in self.directories {
            count += childDirectory.recursiveFileCount
        }
        return count
    }

    /// Whether the directory recursively contains resources
    func recursivelyContains(of assetType: AssetType) -> Bool {
        if self.files.first(where: { $0.assetType == assetType }) != nil {
            return true
        }

        return self.directories.first(where: { $0.recursivelyContains(of: assetType) }) != nil
    }

    /// Files from the directory of a specific type
    func files(of assetType: AssetType) -> [File] {
        return self.files.filter { $0.assetType == assetType }
    }

    /// Add a directory to this directory
    func add(directory: Directory) {
        self.childDirectories[directory.name] = directory
    }
    
    /// Add a file to this directory.
    func add(file: File) {
        self.childFiles[file.name] = file
    }
    
    init(name: String, path: String) {
        self.name = name.capitalizingFirstLetter()
        self.path = path
    }
    
    init?(path: String) {
        guard let last = path.split(separator: "/").last else {
            return nil
        }

        self.name = String(last)
        self.path = path
    }
}

extension Directory: Hashable {
    static func == (lhs: Directory, rhs: Directory) -> Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
    }
}
