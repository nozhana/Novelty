//
//  DefaultsCacheStore.swift
//  Novelty
//
//  Created by Nozhan A. on 7/11/25.
//

import Foundation

final class DefaultsCacheStore {
    private let store: UserDefaults
    
    static let shared = DefaultsCacheStore()
    
    private init(store: UserDefaults = .group) {
        self.store = store
    }
    
    private func getRaw<Value>(_ valueType: Value.Type = Value.self, forKey key: String) -> Value? where Value: Decodable {
        switch valueType {
        case is Bool.Type: store.bool(forKey: key) as? Value
        case is Int.Type: store.integer(forKey: key) as? Value
        case is Float.Type: store.float(forKey: key) as? Value
        case is Double.Type: store.double(forKey: key) as? Value
        case is String.Type: store.string(forKey: key) as? Value
        case is [String].Type: store.stringArray(forKey: key) as? Value
        case is Data.Type: store.data(forKey: key) as? Value
        default:
            if let data = store.data(forKey: key),
               let decoded = try? JSONDecoder().decode(Value.self, from: data) {
                decoded
            } else {
                nil
            }
        }
    }
    
    private func setRaw<Value>(_ value: Value, forKey key: String) where Value: Encodable {
        switch value {
        case is Bool, is Int, is Float, is Double, is String, is [String], is Data:
            store.set(value, forKey: key)
        default:
            if let data = try? JSONEncoder().encode(value) {
                store.set(data, forKey: key)
            }
        }
    }
    
    private func clear(valueForKey key: String) {
        store.removeObject(forKey: key)
    }
    
    func get<Value>(_ valueType: Value.Type = Value.self, forKey key: String) -> Value? where Value: Decodable {
        guard let cached = getRaw(Cached<Value>.self, forKey: key) else { return nil }
        
        if let validValue = cached.validValue {
            return validValue
        }
        
        clear(valueForKey: key)
        return nil
    }
    
    func set<Value>(_ value: Value, forKey key: String, expirationDate: Date) where Value: Encodable {
        let cached = Cached(value, expiresAt: expirationDate)
        setRaw(cached, forKey: key)
    }
    
    func set<Value>(_ value: Value, forKey key: String, timeToLive: TimeInterval) where Value: Encodable {
        let cached = Cached(value, timeToLive: timeToLive)
        setRaw(cached, forKey: key)
    }
}
