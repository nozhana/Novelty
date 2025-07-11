//
//  Serialized.swift
//  Novelty
//
//  Created by Nozhan A. on 7/10/25.
//

import SwiftUI

@propertyWrapper
struct Serialized<Value>: DynamicProperty {
    private var serializer: any Serializer<Value>
    var wrappedValue: Value
    var data: Data {
        get throws {
            try serializer.data(with: wrappedValue)
        }
    }
    
    init(wrappedValue: Value, serializer: any Serializer<Value>) {
        self.wrappedValue = wrappedValue
        self.serializer = serializer
    }
    
    var projectedValue: Serialized<Value> {
        self
    }
}
