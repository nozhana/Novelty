//
//  Serializer.swift
//  Novelty
//
//  Created by Nozhan A. on 7/10/25.
//

import Foundation

protocol Serializer<Value> {
    associatedtype Value
    func data(with value: Value) throws -> Data
    func value(with data: Data) throws -> Value
}

struct JSONSerializer<Value>: Serializer where Value: Codable {}
extension JSONSerializer {
    func data(with value: Value) throws -> Data {
        try JSONEncoder().encode(value)
    }
    
    func value(with data: Data) throws -> Value {
        try JSONDecoder().decode(Value.self, from: data)
    }
}
