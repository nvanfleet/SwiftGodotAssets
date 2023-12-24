import Foundation

class File {
    let url: URL
    
    let name: String
    
    let fileExtension: String
    
    var typeString: String {
        switch self.type {
        case .resource(let typeString):
            return typeString
        default:
            return ""
        }
    }
    
    let type: FileType
    
    init(url: URL, name: String, fileExtension: String, type: FileType) {
        self.url = url
        self.name = name.split(separator: ".").first.map { String($0) } ?? name
        self.fileExtension = fileExtension
        self.type = type
    }
}

extension File: Hashable {
    static func == (lhs: File, rhs: File) -> Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
    }
}
