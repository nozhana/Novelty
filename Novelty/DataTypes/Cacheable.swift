//
//  Cacheable.swift
//  Novelty
//
//  Created by Nozhan A. on 7/11/25.
//

import Foundation

protocol Cacheable<Value> {
    associatedtype Value
    var value: Value { get }
    var expirationDate: Date { get }
}

extension Cacheable {
    var isExpired: Bool {
        expirationDate <= .now
    }
    
    var validValue: Value? {
        isExpired ? nil : value
    }
}

struct Cached<Value>: Cacheable {
    var value: Value
    var expirationDate: Date
    
    init(_ value: Value, expiresAt expirationDate: Date) {
        self.value = value
        self.expirationDate = expirationDate
    }
    
    init(_ value: Value, timeToLive: TimeInterval) {
        self.value = value
        self.expirationDate = .now.advanced(by: timeToLive)
    }
}

extension Cached: Decodable where Value: Decodable {}
extension Cached: Encodable where Value: Encodable {}
