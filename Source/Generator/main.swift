import Foundation

var args = CommandLine.arguments

let assetDirectory = args.count > 1 ? args[1] : "../"
let generatorOutput = args.count > 2 ? args[2] : "../build/AssetsGeneration"

if args.count < 3 {
    print ("Usage is: generator path-to-extension-api output-directory doc-directory")
    print ("- path-to-extensiona-ppi is the full path to extension_api.json from Godot")
    print ("- output-directory is where the files will be placed")
    print ("- doc-directory is the Godot documentation resides (godot/doc)")
    print ("Running with Miguel's testing defaults")
}

do {
    try FileManager.default.createDirectory(atPath: generatorOutput, withIntermediateDirectories: true)
} catch let error {
    print("Error \(error)")
}

if let reader = FileSystemReader(rootPath: assetDirectory), let outputURL = URL(string: generatorOutput) {
    let rootDirectory = reader.searchFilesFromRoot()
    let codeGenerator = CodeGenerator(output: outputURL, rootDirectory: rootDirectory)
    codeGenerator.generate()
}
