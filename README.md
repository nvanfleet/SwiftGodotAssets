# SwiftGodotAssets

## What is SwiftGodotAssets?

SwiftGodotAssets is a tool to generate (at compile time) static asset variables  that can be used to access
resources (images, meshes, scenes etc) within a SwiftGodot project. So instead of dealing with a bunch of 
paths and having to do all the work related keeping those up to date, or finding the paths are broken due to
moves and deletions you can instead just use compile-time code that updates and tells you things are broken. 

TL;DR: If you use resources using SwiftGodot assets you can have more compile-time reliability in regards to
resources in your Godot project.

Code generated will be something like 

```
public enum Scenes {
    public static let characterScene: AssetScene<CustomSceneType> = Asset(path: "res://Scenes/Character.tscn")
}
```

Which would then be referred to in code:

```
let sceneInstance = Scenes.characterScene.instantiate()
self.addChild(node: sceneInstance)
```

A couple notes are:
- If an asset is deleted or moved in your Godot project it could give a runtime error when it's not found.
- If an asset is deleted and then things are recompiled this will throw a compile error instead.

## Setup

The plugin needs to know the root of the godot project it's generating the files for as well as the user's 
specific needs in terms of what kind of file types to generate assets for. 

This is accomplished by creating a configuration file at the root of your SwiftPackage called 
`AssetGeneratorConfiguration.json`. This should have a simple configuration 

```
{
    "asset_path": "<The path to your Godot project root>",
    "asset_types": "<The asset types you want to generate assets for*>",
}
```

The asset types are a string that is a comma seperated list of elements with these options
`image,mesh,scene,script,shader,resource`. See below for more details.

## Supported types

There is a set of supported types for asset generation. This is probably not exhaustive of all the types that
are feasibly supported and more can be added.

### Image

Types: jpg, jpeg, gif, png
Result: Assets of type `CompressedTexture2D`

### Mesh

Types: glb, obj
Result: Assets of type `Mesh`

### Scene

Types: tscn
Result: Assets based on a search of the tscn file which can pull out custom types or specific built in types. 

### Script

Types: gd
Result: Assets of type `Script`

### Shader

Types: gdshader
Result: Assets of type `Shader`

### Resource

Types: tres
Result: Assets of type `Resource`. Since tres files are rather generic I am not sure they could be more 
specific (maybe there can be some determination).
