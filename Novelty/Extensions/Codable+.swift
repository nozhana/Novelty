//
//  Codable+.swift
//  Novelty
//
//  Created by Nozhan A. on 7/10/25.
//

import Foundation

extension String {
    func decodeJson<T>(into type: T.Type) throws -> T where T: Decodable {
        guard let data = data(using: .utf8) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Failed to get UTF8 data from string."))
        }
        let decoded = try JSONDecoder().decode(T.self, from: data)
        return decoded
    }
}

extension Encodable {
    var jsonString: String {
        get throws {
            guard let json = String(data: try jsonData, encoding: .utf8) else {
                throw EncodingError.invalidValue(self, .init(codingPath: [], debugDescription: "Failed to encode value into valid JSON."))
            }
            return json
        }
    }
    
    var jsonData: Data {
        get throws {
            try JSONEncoder().encode(self)
        }
    }
}
