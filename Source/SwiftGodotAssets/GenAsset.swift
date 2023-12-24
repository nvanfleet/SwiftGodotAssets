import Foundation
import SwiftGodot

public struct Asset<T> {
    public let path: String

    public func load(duplicate: Bool = false) -> T? {
        guard let resource = ResourceLoader.load(path: self.path) as? T else {
            GD.print("Asset: Failed to load asset at \(self.path), maybe missing or not a resource")
            return nil
        }

        /// We want to duplicate the asset being loaded
        if duplicate, let duplicated = (resource as? Resource)?.duplicate(subresources: true) as? T {
            return duplicated
        }

        return resource
    }

    public func packed() -> PackedScene? {
        return ResourceLoader.load(path: self.path)
    }

    /// Load and instantiate a scene for the resource
    ///
    /// - duplicate: Whether to create a duplicate of said scene
    ///
    /// - returns: The packed scene.
    public func instantiate(duplicate: Bool = false) -> T? {
        guard let resource = ResourceLoader.load(path: self.path) as? PackedScene else {
            GD.print("Asset: Failed to load the asset \(self.path)")
            return nil
        }

        guard let scene = resource.instantiate() as? T else {
            GD.print("Asset: Failed to instantiate packed scene \(self.path)")
            return nil
        }

        // If we were asked to instantiate a duplicate
        if duplicate, let duplicated: T = (scene as? Node)?.duplicate() as? T {
            return duplicated
        }

        return scene
    }

    /// Load an image from resource.
    ///
    /// - returns: The image from the resource.
    public func loadImage() -> Image? {
        guard let compressed = ResourceLoader.load(path: self.path) as? CompressedTexture2D else {
            GD.print("Failed to load the asset \(self.path)")
            return nil
        }

        return compressed.getImage()
    }

    public init(path: String) {
        self.path = path
    }

    public init(url: URL) {
        self.path = url.absoluteString
    }
}
