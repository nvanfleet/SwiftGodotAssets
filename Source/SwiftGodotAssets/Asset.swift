import Foundation
import SwiftGodot

public struct Asset<T: Resource> {
    /// The path to the resource.
    public let path: String

    /// Load resource of the given type
    ///
    /// - parameter duplicate: Whether to duplicate the resource.
    ///
    /// - returns: The resource.
    public func load(duplicate: Bool = false) throws -> T {
        guard let resource = ResourceLoader.load(path: self.path) as? T else {
            GD.print("Asset: Failed to load asset at \(self.path), maybe missing or not a resource")
            throw(AssetError.fileMissing)
        }

        /// We want to duplicate the asset being loaded
        if duplicate {
            if let duplicated = resource.duplicate(subresources: true) as? T {
                return duplicated
            } else {
                throw(AssetError.duplicateFailure)
            }
        }

        return resource
    }

    public init(path: String) {
        self.path = path
    }
}

extension Asset where T == CompressedTexture2D {
    /// Load the image from a compressed texture
    public func image() throws -> SwiftGodot.Image {
        let resource = try self.load()
        guard let image = resource.getImage() else {
            throw(AssetError.imageLoadFailure)
        }

        return image
    }
}
