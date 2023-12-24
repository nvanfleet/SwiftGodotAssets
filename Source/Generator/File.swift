import Foundation

class File {
    /// The path to the file (masked to the root directory that is being searched)
    let path: String

    /// the name of the file without
    let name: String
    
    /// The file extension of the file
    let fileExtension: String
    
    /// The asset type of the file
    let assetType: AssetType

    /// The type of the file in Godot (Scene, Shader, etc)
    var typeString: String

    /// The godot path of the resource. Truncated to the root directory of the Godot project and using
    /// the res:// scheme
    var godotPath: String { return "res:/\(self.path)" }

    init(path: String, name: String, fileExtension: String, assetType: AssetType, typeString: String) {
        self.path = path
        self.name = name.split(separator: ".").first.map { String($0) } ?? name
        self.fileExtension = fileExtension
        self.assetType = assetType
        self.typeString = typeString
    }
}

extension File: Hashable {
    static func == (lhs: File, rhs: File) -> Bool {
        return lhs.name == rhs.name && lhs.path == rhs.path
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.path)
    }
}
