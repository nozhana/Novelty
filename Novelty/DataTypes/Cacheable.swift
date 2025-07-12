//
//  Cacheable.swift
//  Novelty
//
//  Created by Nozhan A. on 7/11/25.
//

import Foundation

/// A simple interface for a value with an expiration date.
protocol Cacheable<Value> {
    associatedtype Value
    /// The contained value.
    var value: Value { get }
    /// The date after which the cache is considered invalidated.
    var expirationDate: Date { get }
}

extension Cacheable {
    /// `true` if expiration date has passed.
    var isExpired: Bool {
        expirationDate <= .now
    }
    
    /// `nil` if is expired, otherwise the ``value-swift.property`` property.
    var validValue: Value? {
        isExpired ? nil : value
    }
}

struct Cached<Value>: Cacheable {
    var value: Value
    var expirationDate: Date
    
    /// Initialize a ``Cached`` container with the `Date` it expires.
    /// - Parameters:
    ///   - value: The contained value.
    ///   - expirationDate: The `Date` after which the cache is considered expired.
    init(_ value: Value, expiresAt expirationDate: Date) {
        self.value = value
        self.expirationDate = expirationDate
    }
    
    /// Initialize a ``Cached`` container with the `TimeInterval` of its lifecycle.
    /// - Parameters:
    ///   - value: The contained value.
    ///   - timeToLive: Time to live for the cached value, in seconds.
    init(_ value: Value, timeToLive: TimeInterval) {
        self.value = value
        self.expirationDate = .now.advanced(by: timeToLive)
    }
}

extension Cached: Decodable where Value: Decodable {}
extension Cached: Encodable where Value: Encodable {}
