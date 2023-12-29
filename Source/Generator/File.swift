import Foundation

class File {
    /// The directory containing the file
    let directory: Directory

    /// the name of the file without
    let name: String
    
    /// The file extension of the file
    let fileExtension: String
    
    /// The asset type of the file
    let assetType: AssetType

    /// The type of the file in Godot (Scene, Shader, etc)
    var typeString: String

    /// The acutal file system path of the file meaning something like "/Users/<user>/src/GodotProject/..."
    let fullPath: String

    /// The godot path of the resource. Truncated to the root directory of the Godot project and using
    /// the res:// scheme
    let godotPath: String

    /// The accessor path for the variable. So if it's inside 3 enums the return value would be
    /// equal to "One.Two.Three.variableName" and is used when referring to it elsewhere in code.
    var accessorPath: String {
        var currentDirectory: Directory? = self.directory
        var directories = [String]()
        while currentDirectory != nil {
            if let currentDirectory {
                directories.append(currentDirectory.name)
            }

            currentDirectory = currentDirectory?.parent
        }

        directories.reverse()
        directories[0] = self.assetType.classRepresentation
        directories.append(self.name.variableNameString())
        return directories.joined(separator: ".")
    }

    init(fullPath: String, godotPath: String, name: String, fileExtension: String,
         assetType: AssetType, typeString: String, directory: Directory)
    {
        self.fullPath = fullPath
        self.godotPath = "res:/\(godotPath)"
        self.name = name.split(separator: ".").first.map { String($0) } ?? name
        self.fileExtension = fileExtension
        self.assetType = assetType
        self.typeString = typeString
        self.directory = directory
    }
}

extension File: Hashable {
    static func == (lhs: File, rhs: File) -> Bool {
        return lhs.fullPath == rhs.fullPath
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.fullPath)
    }
}
