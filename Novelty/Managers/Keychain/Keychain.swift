//
//  Keychain.swift
//  Novelty
//
//  Created by Nozhan A. on 7/10/25.
//

import SwiftUI

@propertyWrapper
struct Keychain<Value>: DynamicProperty where Value: Codable {
    var manager: KeychainManager = .shared
    var itemClass: KeychainManager.ItemClass
    var key: KeychainManager.Keys
    var attributes: KeychainManager.ItemAttributes? = nil
    @State var wrappedValue: Value? {
        willSet {
            if newValue == nil {
                try? manager.delete(itemClass: itemClass, key: key, attributes: attributes)
            } else {
                do {
                    try manager.save(newValue, itemClass: itemClass, key: key, attributes: attributes)
                } catch let error as KeychainManager.KeychainError {
                    if case .duplicateItem = error {
                        try? manager.update(newValue, itemClass: itemClass, key: key, attributes: attributes)
                    } else {
                        print("Failed to update keychain with value: \(newValue)")
                    }
                } catch {
                    print("Failed to update keychain with value: \(newValue!)")
                }
            }
        }
    }
    
    var projectedValue: Binding<Value?> {
        _wrappedValue.projectedValue
    }
    
    func update() {
        if let newValue = try? manager.get(Value.self, itemClass: itemClass, key: key, attributes: attributes) {
            DispatchQueue.main.async {
                wrappedValue = newValue
            }
        }
    }
}
