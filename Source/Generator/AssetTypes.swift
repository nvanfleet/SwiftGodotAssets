import Foundation

enum AssetType: String {
    case image

    case mesh

    case scene

    case script

    case shader

    case resource

    /// The capitalized version of the type. Example "SceneAssets"
    var fileRepresentation: String {
        return "\(self.rawValue.capitalizingFirstLetter())Assets"
    }

    /// The class representation of the type. Example "Scenes"
    var classRepresentation: String {
        return "\(self.rawValue.capitalizingFirstLetter())s"
    }

    /// Is the asset type a scene
    var isScene: Bool {
        switch self {
        case .scene:
            return true
        default:
            return false
        }
    }

    /// Parse the types that are handled.
    static func fromDeliminated(string: String) -> [AssetType] {
        return string.split(separator: ",").map { AssetType(string: String($0)) }.compactMap { $0 }
    }

    /// The details in regards to a file
    ///
    /// - parameter fileExtension: The file extension of the file.
    /// - parameter path:          The path of the file.
    static func details(for fileExtension: String, at path: String)
    -> (assetType: AssetType, typeString: String)? {
        let validResources: [String: (assetType: AssetType, typeString: String)] = [
            "jpg": (assetType: .image, typeString: "CompressedTexture2D"),
            "jpeg": (assetType: .image, typeString: "CompressedTexture2D"),
            "gif": (assetType: .image, typeString: "CompressedTexture2D"),
            "png": (assetType: .image, typeString: "CompressedTexture2D"),
            "glb": (assetType: .mesh, typeString: "Mesh"),
            "obj": (assetType: .mesh, typeString: "Mesh"),
            "tscn": (assetType: .scene, typeString: "Scene"),
            "gd": (assetType: .script, typeString: "Script"),
            "gdshader": (assetType: .shader, typeString: "Shader"),
            "tres": (assetType: .resource, typeString: "Resource"),
        ]

        let result = validResources[fileExtension.lowercased()]
        if let result, result.assetType == .scene, let determined = Self.determineForScene(at: path) {
            return (assetType: result.assetType, typeString: determined)
        }

        return result

    }

    init?(string: String) {
        switch string {
        case "image":
            self = AssetType.image
        case "mesh":
            self = AssetType.mesh
        case "scene":
            self = AssetType.scene
        case "script":
            self = AssetType.script
        case "shader":
            self = AssetType.shader
        case "resource":
            self = AssetType.resource
        default:
            return nil
        }
    }

    // MARK: - Private

    private static func determineForScene(at path: String) -> String? {
        guard let fileData = FileManager.default.contents(atPath: path),
              let fileString = String(data: fileData, encoding: .utf8) else {
            print("Scene file type determination failed")
            return nil
        }

        // Parse the format [node name="Cube" type="Spatial" parent="."]
        for line in fileString.components(separatedBy: .newlines) {
            // Look for a node declaration with no parent which means it's the root
            if line.hasPrefix("[node") && line.contains("parent=") == false {
                if let found = self.findType(in: line) {
                    return found
                } else if fileString.contains("3D") {
                    // No type on the root node, so there is a default value, determine 3D
                    return "Node3D"
                } else if fileString.contains("2D") {
                    // No type on the root node, so there is a default value, determine 2D
                    return "Node2D"
                }
            }
        }

        print("Could not determine scene type")
        return nil
    }

    private static func findType(in line: String) -> String? {
        for piece in line.split(separator: " ") {
            if piece.contains("type=") {
                // Find the type in the root node
                let piecePart = piece.split(separator: "=")
                return String(piecePart[1]).filterAlphaNumeric()
            }
        }

        return nil
    }
}

extension String {
    func filterAlphaNumeric() -> String {
        // Create a regular expression pattern to match non-alphanumeric characters
        let pattern = "[^a-zA-Z0-9]"

        // Create a regular expression object
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return self
        }

        // Use the regular expression to replace non-alphanumeric characters with an empty string
        let filteredString = regex
            .stringByReplacingMatches(in: self, options: [],
                                      range: NSRange(location: 0, length: self.utf16.count),
                                      withTemplate: "")

        return filteredString
    }

    /// A compliant swift variable name
    func variableNameString() -> String {
        let string: String

        // Handle the case where the name starts with a number which is not supported in swift
        if let first = self.first, Int(String(first)) != nil {
            string = "variable_\(self)"
        // Check if the first character is lowercase, otherwise lowercase the string
        } else if count > 1, self.first?.isLowercase == false {
            string = String(prefix(1).lowercased() + dropFirst())
        } else {
            string = self
        }

        // filter out whitespace to make things valid. Replace dashes with underscores
        return string.filter{ $0.isWhitespace == false }.replacing("-", with: "_")
    }
}

extension StringProtocol {
    func capitalizingFirstLetter() -> Self {
        guard !isEmpty else {
            return self
        }
        return Self(prefix(1).uppercased() + dropFirst())!
    }

    func lowercasingFirstLetter() -> Self {
        // avoid lowercasing single letters (I), or capitalized multiples (AThing ! to aThing, leave as AThing)
        guard count > 1, !(String(prefix(2)) == prefix(2).lowercased()) else {
            return self
        }
        return Self(prefix(1).lowercased() + dropFirst())!
    }
}
