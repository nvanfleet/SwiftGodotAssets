import Foundation
import SwiftGodot

/// Vector3 Shader implementation
public enum Vector3ShaderOption {
    case vector3(Vector3)
    case color(Color)

    public func variantStorable() -> any VariantStorable {
        switch self {
        case .vector3(let vector3):
            return vector3
        case .color(let color):
            return color
        }
    }

    public init?(_ variant: Variant) {
        if let vector3 = Vector3(variant) {
            self = .vector3(vector3)
        } else if let color = Color(variant) {
            self = .color(color)
        } else {
            return nil
        }
    }
}

/// Vector4 Shader implementation
public enum Vector4ShaderOption {
    case vector4(Vector4)
    case color(Color)
    case rect2(Rect2)
    case plane(Plane)
    case quaternion(Quaternion)

    public func variantStorable() -> any VariantStorable {
        switch self {
        case .vector4(let vector4):
            return vector4
        case .color(let color):
            return color
        case .rect2(let rect2):
            return rect2
        case .plane(let plane):
            return plane
        case .quaternion(let quaternion):
            return quaternion
        }
    }

    public init?(_ variant: Variant) {
        if let vector4 = Vector4(variant) {
            self = .vector4(vector4)
        } else if let color = Color(variant) {
            self = .color(color)
        } else if let rect2 = Rect2(variant) {
            self = .rect2(rect2)
        } else if let plane = Plane(variant) {
            self = .plane(plane)
        } else if let quaternion = Quaternion(variant) {
            self = .quaternion(quaternion)
        } else {
            return nil
        }
    }
}

/// Matrix4 shader implementation
public enum Matrix4ShaderOption {
    case projection(Projection)
    case transform3D(Transform3D)

    public func variantStorable() -> any VariantStorable {
        switch self {
        case .projection(let projection):
            return projection
        case .transform3D(let transform3D):
            return transform3D
        }
    }

    public init?(_ variant: Variant) {
        if let projection = Projection(variant) {
            self = .projection(projection)
        } else if let transform = Transform3D(variant) {
            self = .transform3D(transform)
        } else {
            return nil
        }
    }
}
