//
//  Encrypted.swift
//  Novelty
//
//  Created by Nozhan A. on 7/11/25.
//

import Foundation
import CommonCrypto

/// An encrypted box that uses an ``AES`` instance to securely encrypt and decrypt any codable value.
///  
/// ## Example usage:
/// ```swift
/// let intBox = Encrypted(1984, with: "George Orwell")
/// let value = try! intBox.unbox(password: "George Orwell")
/// print(value)
/// // 1984
/// ```
struct Encrypted<Value>: Codable where Value: Codable {
    private var encryptedData: Data
    private var encryptedPassword: Data
    
    /// Initialize an ``Encrypted`` box with a value and a string password.
    ///
    /// ## Example usage:
    /// ```swift
    /// let box = Encrypted(codableValue, with: "MyPassword")
    /// ```
    init(_ value: Value, with password: String) throws(CryptError) {
        let aes = AES()
        guard let passwordData = password.data(using: .utf8),
              let encryptedPassword = aes.encrypt(passwordData) else {
            throw .failedToEncryptInputPassword
        }
        do {
            let encodedData = try JSONEncoder().encode(value)
            guard let encryptedData = aes.encrypt(encodedData) else {
                throw CryptError.failedToEncryptValueData
            }
            self.encryptedData = encryptedData
            self.encryptedPassword = encryptedPassword
        } catch let error as EncodingError {
            throw .encodingError(error)
        } catch let error as CryptError {
            throw error
        } catch {
            throw .unknown(error)
        }
    }
    
    /// Attempts to decrypt the content of an ``Encrypted`` box using a string password.
    ///
    /// ## Example usage:
    /// ```swift
    /// let intBox = Encrypted(1984, with: "George Orwell")
    /// let value = try! intBox.unbox(password: "George Orwell")
    /// print(value)
    /// // 1984
    /// ```
    func unbox(password: String) throws(CryptError) -> Value {
        let aes = AES()
        guard let passwordData = password.data(using: .utf8),
              let encrypted = aes.encrypt(passwordData) else {
            throw .failedToEncryptInputPassword
        }
        guard encrypted == encryptedPassword else {
            throw .invalidPassword
        }
        guard let decryptedData = aes.decrypt(encryptedData) else {
            throw .failedToDecryptValueData
        }
        do {
            let decoded = try JSONDecoder().decode(Value.self, from: decryptedData)
            return decoded
        } catch let error as DecodingError {
            throw .decodingError(error)
        } catch {
            throw .unknown(error)
        }
    }
}

/// Thrown when ``Encrypted/unbox(password:)`` fails.
enum CryptError: Error {
    /// Used an invalid password when unboxing an encrypted value.
    case invalidPassword
    /// Failed to encrypt input password.
    case failedToEncryptInputPassword
    /// Failed to decrypt value data.
    case failedToDecryptValueData
    /// Failed to encrypt value data.
    case failedToEncryptValueData
    /// Thrown a `DecodingError` during unboxing.
    case decodingError(DecodingError)
    /// Thrown an `EncodingError` during unboxing.
    case encodingError(EncodingError)
    /// Thrown an unknown error during unboxing.
    case unknown(Error)
}

/// A customized instance of an `AES` crypt with a custom key and initialization vector.
///
/// - Note: Key: `8Gjn5pqkUymquALZZQCmIg==`
/// - Note: IV: `2825dc1ee41922a50e81fbe69e124dfd`
///
/// ## Example Usage:
/// ```swift
/// let aes = AES()
/// let dataToEncrypt = "Hello, World!".data(using: .utf8)!.base64EncodedData()
/// let encryptedData = aes.encrypt(dataToEncrypt)!
/// let decryptedData = aes.decrypt(encryptedData)!
/// let decodedData = Data(base64Encoded: decryptedData)!
/// let decodedString = String(data: decodedData, encoding: .utf8)!
/// print(decodedString)
/// // "Hello, World!"
/// ```
struct AES {
    /// The encryption key used in the `AES-128-GCM` cryptographic algorithm.
    let key = "8Gjn5pqkUymquALZZQCmIg==".data(using: .utf8)!
    /// The initialization vector used in the `AES-128-GCM` cryptographic algorithm.
    let iv = "2825dc1ee41922a50e81fbe69e124dfd".data(using: .utf8)!
    
    // TODO: Incorporate MD5 hash
    /// The MD5 hash used in hashing the password data
    ///
    /// - Warning: Not used as of now.
    let md5hash = "ebf5b3988cfeea9cf98fb751c52fd576"
    
    /// Encrypt data using the `AES-128-GCM` algorithm.
    /// - Parameter data: Input data to be encrypted.
    /// - Returns: Optional encrypted data.
    func encrypt(_ data: Data) -> Data? {
        crypt(data: data, operation: CCOperation(kCCEncrypt))
    }
    
    /// Decrypt data using the `AES-128-GCM` algorithm.
    /// - Parameter data: Input data to be decrypted.
    /// - Returns: Optional decrypted data.
    func decrypt(_ data: Data) -> Data? {
        crypt(data: data, operation: CCOperation(kCCDecrypt))
    }
    
    /// Main cryptography logic. Encrypts or decrypts given data using the `AES-128-GCM` algorithm.
    /// - Parameters:
    ///   - data: Input optional data to be encrypted or decrypted.
    ///   - operation: A `CCOperation` that indicates an encryption/decryption operation.
    /// - Returns: Optional encrypted/decrypted data.
    private func crypt(data: Data?, operation: CCOperation) -> Data? {
        guard let data else { return nil }
        
        let cryptLength = data.count + key.count
        var cryptData = Data(count: cryptLength)
        
        var bytesLength = 0
        
        let status = cryptData.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                iv.withUnsafeBytes { ivBytes in
                    key.withUnsafeBytes { keyBytes in
                        CCCrypt(operation, CCAlgorithm(kCCAlgorithmAES), CCOptions(kCCOptionPKCS7Padding), keyBytes.baseAddress, key.count, ivBytes.baseAddress, dataBytes.baseAddress, data.count, cryptBytes.baseAddress, cryptLength, &bytesLength)
                    }
                }
            }
        }
        
        guard Int32(status) == Int32(kCCSuccess) else {
            print("Failed to crypt data: \(status)")
            return nil
        }
        
        cryptData.removeSubrange(bytesLength..<cryptData.count)
        return cryptData
    }
}
