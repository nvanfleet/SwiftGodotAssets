import Foundation
import SwiftGodot

public struct AssetScene<T: Node> {
    /// The path to the resource.
    public let path: String

    /// Load resource of the given type
    ///
    /// - parameter duplicate: Whether to duplicate the resource.
    ///
    /// - returns: The resource.
    public func load(duplicate: Bool = false) throws -> PackedScene {
        let asset = Asset<PackedScene>(path: self.path)
        return try asset.load(duplicate: duplicate)
    }

    /// Load and instantiate a scene for the resource
    ///
    /// - duplicate: Whether to create a duplicate of said scene
    ///
    /// - returns: The packed scene.
    public func instantiate(duplicate: Bool = false) throws -> T {
        let loaded = try self.load(duplicate: duplicate)
        guard let instantiated = loaded.instantiate() as? T else {
            throw(AssetError.instantiateFailure)
        }

        // If we were asked to instantiate a duplicate
        if duplicate {
            if let duplicated = instantiated.duplicate() as? T {
                return duplicated
            } else {
                throw(AssetError.duplicateFailure)
            }
        }

        return instantiated
    }

    public init(path: String) {
        self.path = path
    }
}

public extension AssetScene: Hashable {
    static func == (lhs: AssetScene, rhs: AssetScene) -> Bool {
        return lhs.path == rhs.path
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.path)
    }
}
