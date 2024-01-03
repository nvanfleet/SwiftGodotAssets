import Foundation

// https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/shading_language.html
private let kLookup = [
    "bool": "Bool",
    "bvec2": "Int",
    "bvec3": "Int",
    "bvec4": "Int",
    "int": "Int",
    "ivec2": "Vector2i",
    "ivec3": "Vector3i",
    "ivec4": "Vector4i",
    "uint": "UInt",
    "uvec2": "Vector2i",
    "uvec3": "Vector3i",
    "uvec4": "Vector4i",
    "float": "Float",
    "vec2": "Vector2",
    "vec3": "Vector3ShaderOption",
    "vec4": "Vector4ShaderOption",
    "mat2": "Transform2D",
    "mat3": "Basis",
    "mat4": "Matrix4ShaderOption",
    "sampler2D": "Texture2D",
    "isampler2D": "Texture2D",
    "usampler2D": "Texture2D",
    "sampler2DArray": "Texture2DArray",
    "isampler2DArray": "Texture2DArray",
    "usampler2DArray": "Texture2DArray",
    "sampler3D": "Texture3D",
    "isampler3D": "Texture3D",
    "usampler3D": "Texture3D",
    "samplerCube": "Cubemap",
    "sampleCubeArray": "CubemapArray",
]

private let kObjectLookup = [
    "Texture2D",
    "Texture3D",
    "Cubemap",
]

private let kClosing = "}"

/// Editor

private let kEditorClass = """
/// Shader Editor for the shader at %@
public final class %@ShaderEditor {
    private let shaderMaterial: ShaderMaterial
"""
private let kEditorInit = """
    public init?(_ shaderMaterial: ShaderMaterial) {
        guard shaderMaterial.shader.resourcePath == "%@" else {
            return nil
        }

        self.shaderMaterial = shaderMaterial
    }
"""
private let kShaderEditorGetSet = """
    public var %@: %@? {
        get {
            return %@
        }
        set {
            if let newValue {
                self.shaderMaterial.setShaderParameter(param: "%@", value: %@)
            }
        }
    }
"""

let kNonClassVariable = "%@(self.shaderMaterial.getShaderParameter(param: \"%@\"))"
let kClassVariable = "self.shaderMaterial.getShaderParameter(param: \"%@\").asObject() as? %@"

/// Accessor

private let kEditorAccessor = """
    /// Access an editor of a type of a Shader Material that uses the shader at '%@'
    public var get%@Editor: %@ShaderEditor? {
        return %@ShaderEditor(self)
    }
"""

/// Constructing

private let kShaderAndEditorAccessor = """
    /// Shader material and editor for the shader at %@
    public static func get%@ShaderMaterial() -> (material: ShaderMaterial, editor: %@ShaderEditor?) {
        let shaderMaterial = ShaderMaterial()
        let asset = Asset<Shader>(path: "%@")
        shaderMaterial.shader = try asset.load()

        guard let editor = %@ShaderEditor(shaderMaterial) else {
            return (material: shaderMaterial, editor: nil)
        }

        return (material: shaderMaterial, editor: editor)
    }
"""

struct ShaderClass {
    let name: String
    let variables: [ShaderVariable]
    let shaderFile: File

    /// The class code accessing a shader material and editor
    func accessorCode() -> [String] {
        let shaderAddress = self.shaderFile.accessorPath
        var output = [""]
        let accessorValue = String(format: kShaderAndEditorAccessor, shaderAddress, self.name, self.name,
                                 self.shaderFile.godotPath, self.name)
        output.append(contentsOf: accessorValue.components(separatedBy: .newlines))
        return output
    }

    /// The class code for accessing an editor off an existing ShaderMaterial
    func editorAccessorCode() -> [String] {
        let shaderAddress = self.shaderFile.accessorPath
        var output = [""]
        let accessorValue = String(format: kEditorAccessor, shaderAddress, self.name, self.name, self.name)
        output.append(contentsOf: accessorValue.components(separatedBy: .newlines))
        return output
    }

    /// The class code for the shader material
    func editorCode() -> [String] {
        let shaderAddress = self.shaderFile.accessorPath
        let className = String(format: kEditorClass, shaderAddress, self.name).components(separatedBy: .newlines)
        let classInit = String(format: kEditorInit, shaderFile.godotPath).components(separatedBy: .newlines)
        var output = className + [""] + classInit
        for variable in self.variables {
            guard let swiftType = variable.swiftGodotType else {
                print("Failed to determine shader \(variable.parameter) \(variable.type)")
                continue
            }

            // Bridge the enum to make it capable of storing into an enum.
            let variantCreation: String
            if swiftType.contains("ShaderOption") {
                variantCreation = "Variant(newValue.variantStorable())"
            } else {
                variantCreation = "Variant(newValue)"
            }

            let getValue: String
            if variable.isObject {
                getValue = String(format: kClassVariable, variable.parameter, swiftType)
            } else {
                getValue = String(format: kNonClassVariable, swiftType, variable.parameter)
            }

            output.append("")
            let getSetValue = String(format: kShaderEditorGetSet, variable.variableName, swiftType, getValue,
                                     variable.parameter, variantCreation)
            output.append(contentsOf: getSetValue.components(separatedBy: .newlines))
        }
        output.append(kClosing)
        return output
    }

    init(name: String, variables: [ShaderVariable], shaderFile: File) {
        let ultimateName: String
        if name.hasSuffix("ShaderMaterial") {
            ultimateName = name.replacingOccurrences(of: "ShaderMaterial", with: "")
        } else if name.hasSuffix("Shader") {
            ultimateName = name.replacingOccurrences(of: "Shader", with: "")
        } else if name.hasSuffix("Material") {
            ultimateName = name.replacingOccurrences(of: "Material", with: "")
        } else {
            ultimateName = name
        }

        self.name = ultimateName
        self.variables = variables
        self.shaderFile = shaderFile
    }
}

struct ShaderVariable {
    let type: String
    let parameter: String

    /// Name for the uniform value used in the functions. uv1_scale would be "Uv1Scale" for functions
    /// like "getUv1Scale" and "setUv1Scale"
    var functionName: String {
        var output = ""
        var capitalize = true
        for character in self.parameter {
            if character == "_" {
                capitalize = true
                continue
            }

            let string = String(character)
            output += capitalize ? string.capitalized : string
            capitalize = false
        }

        return output
    }

    /// Name for the uniform value used in the variable. uv1_scale would be "uv1Scale" for functions
    /// like "getUv1Scale" and "setUv1Scale"
    var variableName: String {
        var output = ""
        var capitalize = false
        for character in self.parameter {
            if character == "_" {
                capitalize = true
                continue
            }

            let string = String(character)
            output += capitalize ? string.capitalized : string
            capitalize = false
        }

        return output
    }

    /// Whether the swift type is a godot object and is allocated that way
    var isObject: Bool {
        if let swiftType = self.swiftGodotType {
            return kObjectLookup.contains(swiftType)
        }

        return false
    }

    /// The Swift Godot type that is to be
    var swiftGodotType: String? {
        return kLookup[type]
    }
}
