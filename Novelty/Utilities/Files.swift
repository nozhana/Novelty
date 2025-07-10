//
//  Files.swift
//  Novelty
//
//  Created by Nozhan A. on 7/10/25.
//

import SwiftUI

@propertyWrapper
struct Files<Value>: DynamicProperty where Value: Codable {
    var containerPath: URL
    var relativePath: String
    var manager: FileManager
    var wrappedValue: Value {
        get {
            let data = manager.contents(atPath: path.absoluteString)!
            let decoded = try! JSONDecoder().decode(Value.self, from: data)
            return decoded
        }
        set {
            let data = try! JSONEncoder().encode(newValue)
            try? manager.removeItem(at: path)
            manager.createFile(atPath: path.absoluteString, contents: data)
        }
    }
    
    init(wrappedValue: Value, _ relativePath: String, containerPath: URL = .documentsDirectory, manager: FileManager = .default) {
        self.containerPath = containerPath
        self.relativePath = relativePath
        self.manager = manager
        if !manager.fileExists(atPath: path.absoluteString) {
            do {
                try manager.createDirectory(at: self.containerPath, withIntermediateDirectories: true)
                let data = try JSONEncoder().encode(wrappedValue)
                manager.createFile(atPath: path.absoluteString, contents: data)
            } catch {
                fatalError("Failed to create file: \(error)")
            }
        }
    }
    
    var path: URL {
        containerPath.appending(path: relativePath)
    }
    
    var projectedValue: Files<Value> {
        self
    }
}
