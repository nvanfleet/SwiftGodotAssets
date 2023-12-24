import Foundation

class Directory {
    private(set) var childDirectories = [String: Directory]()
    private var childFiles = [String: File]()
    
    let name: String
    
    let componentCount: Int
    
    var files: [File] { self.childFiles.map { $0.value } }
    
    var directories: [Directory] { self.childDirectories.map { $0.value } }
    
    var hasFiles: Bool { self.files.isEmpty == false }
    
    // Whether the directory recursively contains resources
    lazy var recursivelyContainsResources: Bool = {
        guard self.files.isEmpty else {
            return true
        }
        
        return self.directories.first(where: { $0.recursivelyContainsResources == true }) != nil
    }()
    
    func add(directory: Directory) {
        self.childDirectories[directory.name] = directory
    }
    
    func add(file: File) {
        self.childFiles[file.name] = file
    }
    
    init(name: String, componentCount: Int) {
        self.name = name
        self.componentCount = componentCount
    }
    
    init?(url: URL?) {
        guard let url, let last = url.pathComponents.last else {
            return nil
        }
        
        let components = url.pathComponents
        self.name = last
        self.componentCount = components.count
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
