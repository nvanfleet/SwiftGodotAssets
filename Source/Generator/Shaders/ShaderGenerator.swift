import Foundation

private let kEditorExtension = "public extension ShaderMaterial {"
private let kShaderMaterials = "public enum ShaderMaterials {"
private let kClose = "}"

/// Include shaders with no uniforms into the Shader Material Library
private let kIncludeNoUniformShaders = true

/// A class to generate custom ShaderMaterials for given shaders that are found within the project.
final class ShaderGenerator {
    private let rootDirectory: Directory
    private var classes = [String: ShaderClass]()

    /// Generate all definitions for shaders
    func generateAllShaders() {
        let allShaders = self.rootDirectory.recursiveFiles(of: .shader)
        allShaders.forEach { self.generate(for: $0) }
    }

    /// All the code related to generated shader material
    func accessorCode() -> [String] {
        var output = [String]()
        output.append(kShaderMaterials)
        for (_, shaderClass) in self.classes.sorted(by: { $0.0 < $1.0 }) {
            output.append(contentsOf: shaderClass.accessorCode())
        }
        output.append(kClose)

        return output
    }

    func editorAccessorCode() -> [String] {
        var output = [String]()
        output.append(kEditorExtension)
        for (_, shaderClass) in self.classes.sorted(by: { $0.0 < $1.0 }) {
            output.append(contentsOf: shaderClass.editorAccessorCode())
        }
        output.append(kClose)

        return output
    }

    /// All the code related to generated shader material
    func editorCode() -> [String] {
        var output = [String]()
        for (_, shaderClass) in self.classes.sorted(by: { $0.0 < $1.0 }) {
            output.append("")
            output.append(contentsOf: shaderClass.editorCode())
        }

        return output
    }

    init(rootDirectory: Directory) {
        self.rootDirectory = rootDirectory
    }

    // MARK: - Private

    private func generate(for shaderFile: File) {
        guard let fileData = FileManager.default.contents(atPath: shaderFile.fullPath),
              let fileString = String(data: fileData, encoding: .utf8) else {
            print("Scene file type determination failed")
            return
        }

        var shaderVariables = [ShaderVariable]()
        for line in fileString.components(separatedBy: .newlines) {
            // Look for a node declaration with no parent which means it's the root
            if line.hasPrefix("uniform") {
                let components = line.split(separator: " ")
                if components.count >= 3 {
                    let type = String(components[1])
                    var parameter = String(components[2])
                    if let last = parameter.last, [":", ";", "="].contains(last) {
                        _ = parameter.removeLast()
                    }

                    shaderVariables.append(ShaderVariable(type: type, parameter: parameter))
                }
            }
        }

        guard shaderVariables.count > 0 || kIncludeNoUniformShaders else {
            return
        }

        let className = self.determineName(for: shaderFile)
        self.classes[className] = ShaderClass(name: className, variables: shaderVariables,
                                              shaderFile: shaderFile)
    }

    private func determineName(for shaderFile: File) -> String {
        var name = shaderFile.name
        var counter = 1
        while self.classes[name] != nil {
            name = "\(shaderFile.name)\(counter)"
            counter += 1
        }

        return name
    }
}
