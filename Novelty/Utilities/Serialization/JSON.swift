//
//  JSON.swift
//  Novelty
//
//  Created by Nozhan A. on 7/10/25.
//

import SwiftUI

@dynamicMemberLookup
@propertyWrapper
struct JSON<Value>: DynamicProperty where Value: Codable {
    private var serializer: JSONSerializer<Value>
    var wrappedValue: Value
    var data: Data {
        try! serializer.data(with: wrappedValue)
    }
    var jsonString: String {
        String(data: data, encoding: .utf8)!
    }
    
    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
        self.serializer = JSONSerializer()
    }
    
    var projectedValue: JSON<Value> {
        self
    }
    
    subscript<Child>(dynamicMember keyPath: KeyPath<Value, Child>) -> JSON<Child> {
        JSON<Child>(wrappedValue: wrappedValue[keyPath: keyPath])
    }
}
