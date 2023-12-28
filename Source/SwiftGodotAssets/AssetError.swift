import Foundation

public enum AssetError: Error {
    case fileMissing
    case instantiateFailure
    case duplicateFailure
    case imageLoadFailure
}
