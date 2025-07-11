//
//  KeychainManager.swift
//  Novelty
//
//  Created by Nozhan A. on 7/10/25.
//

import Foundation

final class KeychainManager {
    typealias ItemAttributes = [CFString: AnyObject]
    
    static let shared = KeychainManager()
    private init() {}
}

extension KeychainManager {
    enum ItemClass: RawRepresentable {
        typealias RawValue = CFString
        
        case generic
        case password
        case certificate
        case cryptography
        case identity
        
        init?(rawValue: CFString) {
            switch rawValue {
            case kSecClassGenericPassword:
                self = .generic
            case kSecClassInternetPassword:
                self = .password
            case kSecClassCertificate:
                self = .certificate
            case kSecClassKey:
                self = .cryptography
            case kSecClassIdentity:
                self = .identity
            default:
                return nil
            }
        }
        
        var rawValue: CFString {
            switch self {
            case .generic:
                return kSecClassGenericPassword
            case .password:
                return kSecClassInternetPassword
            case .certificate:
                return kSecClassCertificate
            case .cryptography:
                return kSecClassKey
            case .identity:
                return kSecClassIdentity
            }
        }
    }
}

extension KeychainManager {
    enum KeychainError: Error {
        case invalidData
        case itemNotFound
        case duplicateItem
        case incorrectAttributeForClass
        case unexpected(OSStatus)
        
        var localizedDescription: String {
            switch self {
            case .invalidData:
                return "Invalid data"
            case .itemNotFound:
                return "Item not found"
            case .duplicateItem:
                return "Duplicate Item"
            case .incorrectAttributeForClass:
                return "Incorrect Attribute for Class"
            case .unexpected(let oSStatus):
                return "Unexpected error - \(oSStatus)"
            }
        }
    }
    
    private func keychainError(from error: OSStatus) -> KeychainError {
        switch error {
        case errSecItemNotFound:
            return .itemNotFound
        case errSecDataTooLarge:
            return .invalidData
        case errSecDuplicateItem:
            return .duplicateItem
        default:
            return .unexpected(error)
        }
    }
}

extension KeychainManager {
    enum Keys: CustomStringConvertible {
        case storyPasswords
        
        var description: String {
            switch self {
            case .storyPasswords:
                "story.passwords"
            }
        }
    }
}

extension KeychainManager {
    func save<T>(_ value: T, itemClass: ItemClass, key: Keys, attributes: ItemAttributes? = nil) throws where T: Encodable {
        let data = try JSONEncoder().encode(value)
        
        var query: [String: AnyObject] = [
            kSecClass as String: itemClass.rawValue,
            kSecAttrAccount as String: key.description as AnyObject,
            kSecValueData as String: data as AnyObject
        ]
        
        if let attributes {
            for (key, value) in attributes {
                query[key as String] = value
            }
        }
        
        let result = SecItemAdd(query as CFDictionary, nil)
        
        if result != errSecSuccess {
            throw keychainError(from: result)
        }
    }
    
    func get<T>(_ valueType: T.Type = T.self, itemClass: ItemClass, key: Keys, attributes: ItemAttributes? = nil) throws -> T where T: Decodable {
        var query: [String: AnyObject] = [
            kSecClass as String: itemClass.rawValue,
            kSecAttrAccount as String: key.description as AnyObject,
            kSecReturnAttributes as String: true as AnyObject,
            kSecReturnData as String: true as AnyObject
        ]
        
        if let attributes {
            for(key, value) in attributes {
                query[key as String] = value
            }
        }
        
        var item: CFTypeRef?
        let result = SecItemCopyMatching(query as CFDictionary, &item)
        
        if result != errSecSuccess {
            throw keychainError(from: result)
        }
        
        guard let dictionary = item as? [String: Any],
              let data = dictionary[kSecValueData as String] as? Data else { throw KeychainError.invalidData }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func update<T: Encodable>(_ item: T, itemClass: ItemClass, key: Keys, attributes: ItemAttributes? = nil) throws {
        let data = try JSONEncoder().encode(item)
        
        var query: [String: AnyObject] = [
            kSecClass as String: itemClass.rawValue,
            kSecAttrAccount as String: key.description as AnyObject
        ]
        
        if let attributes {
            for(key, value) in attributes {
                query[key as String] = value
            }
        }
        
        let attributesToUpdate: [String: AnyObject] = [
            kSecValueData as String: data as AnyObject
        ]
        
        let result = SecItemUpdate(
            query as CFDictionary,
            attributesToUpdate as CFDictionary
        )
        
        if result != errSecSuccess {
            throw keychainError(from: result)
        }
    }
    
    func delete(itemClass: ItemClass, key: Keys, attributes: ItemAttributes? = nil) throws {
        var query: [String: AnyObject] = [
            kSecClass as String: itemClass.rawValue,
            kSecAttrAccount as String: key.description as AnyObject
        ]
        
        if let attributes {
            for(key, value) in attributes {
                query[key as String] = value
            }
        }
        
        let result = SecItemDelete(query as CFDictionary)
        
        if result != errSecSuccess {
            throw keychainError(from: result)
        }
    }
}
