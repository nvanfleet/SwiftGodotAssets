import Foundation

private let kSkipDirectories = false

class Directory {
    private(set) var childDirectories = [String: Directory]()
    private var childFiles = [String: File]()

    /// Parent directory
    let parent: Directory?

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

    /// Skips forward to a deeper directory if the initial ones contain nothing at all to do with the asset.
    /// Effective for well organized projects that have all shaders in the "Shaders" directory etc. 
    ///
    /// But as new files are added to the project it may mutate the enums and break the references to some
    /// things. For example if all shaders are in the shaders directory it would be Shaders.shaderFile. But if
    /// you added a shader into a Test directory it would change to Shaders.Shaders.shaderFile and
    /// Shaders.Test.shaderFile.
    func skipToDirectory(for assetType: AssetType) -> Directory? {
        guard kSkipDirectories else {
            return nil
        }

        var currentDirectory = self
        while currentDirectory.directories.isEmpty == false {
            guard currentDirectory.files(of: assetType).isEmpty else {
                break
            }

            let diretoriesContainingType = currentDirectory.directories.filter { directory in
                directory.recursivelyContains(of: assetType)
            }

            if diretoriesContainingType.count == 1, let directory = diretoriesContainingType.first {
                currentDirectory = directory
            } else if diretoriesContainingType.count > 1 {
                break
            }
        }

        return currentDirectory
    }

    /// Files from the directory of a specific type
    func files(of assetType: AssetType) -> [File] {
        return self.files.filter { $0.assetType == assetType }
    }

    /// Returns all the files of the given type from itself and all child directories
    func recursiveFiles(of assetType: AssetType) -> [File] {
        return self.files(of: assetType) + self.directories.flatMap { $0.recursiveFiles(of: assetType) }
    }

    /// Add a directory to this directory
    func add(directory: Directory) {
        self.childDirectories[directory.name] = directory
    }
    
    /// Add a file to this directory.
    func add(file: File) {
        self.childFiles[file.name] = file
    }
    
    init(name: String, path: String, parent: Directory? = nil) {
        self.name = name.capitalizingFirstLetter()
        self.path = path
        self.parent = parent
    }
    
    init?(path: String) {
        guard let last = path.split(separator: "/").last else {
            return nil
        }

        self.name = String(last)
        self.path = path
        self.parent = nil
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
