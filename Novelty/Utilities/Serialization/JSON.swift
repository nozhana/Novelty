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
        get throws {
            try serializer.data(with: wrappedValue)
        }
    }
    var jsonString: String {
        get throws {
            String(data: try data, encoding: .utf8) ?? ""
        }
    }
    
    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
        self.serializer = JSONSerializer()
    }
    
    init(ofType valueType: Value.Type = Value.self, data: Data) throws {
        let serializer = JSONSerializer<Value>()
        let value = try serializer.value(with: data)
        self.wrappedValue = value
        self.serializer = serializer
    }
    
    init(ofType valueType: Value.Type = Value.self, data: Data) where Value: OptionalProtocol {
        let serializer = JSONSerializer<Value>()
        let value = try? serializer.value(with: data)
        self.wrappedValue = value ?? nil
        self.serializer = serializer
    }
    
    var projectedValue: JSON<Value> {
        self
    }
    
    subscript<Child>(dynamicMember keyPath: KeyPath<Value, Child>) -> JSON<Child> {
        JSON<Child>(wrappedValue: wrappedValue[keyPath: keyPath])
    }
}

protocol OptionalProtocol: ExpressibleByNilLiteral {
    associatedtype Wrapped
    var wrappedValue: Wrapped? { get set }
}

extension Optional: OptionalProtocol {
    var wrappedValue: Wrapped? {
        get { self }
        set { self = newValue }
    }
}
