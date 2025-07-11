//
//  Encrypted.swift
//  Novelty
//
//  Created by Nozhan A. on 7/11/25.
//

import Foundation
import CommonCrypto

struct Encrypted<Value>: Codable where Value: Codable {
    private var encryptedData: Data
    private var encryptedPassword: Data
    
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

enum CryptError: Error {
    case invalidPassword
    case failedToEncryptInputPassword
    case failedToDecryptValueData
    case failedToEncryptValueData
    case decodingError(DecodingError)
    case encodingError(EncodingError)
    case unknown(Error)
}

struct AES {
    let key = "8Gjn5pqkUymquALZZQCmIg==".data(using: .utf8)!
    let iv = "2825dc1ee41922a50e81fbe69e124dfd".data(using: .utf8)!
    
    let md5hash = "ebf5b3988cfeea9cf98fb751c52fd576"
    
    func encrypt(_ data: Data) -> Data? {
        crypt(data: data, operation: CCOperation(kCCEncrypt))
    }
    
    func decrypt(_ data: Data) -> Data? {
        crypt(data: data, operation: CCOperation(kCCDecrypt))
    }
    
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
