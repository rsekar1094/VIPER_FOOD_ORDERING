//
//  AppEncoderAndDecoder.swift
//  SwiftUIMVVM
//
//  Created by Rajasekar on 09/07/21.
//

import Foundation

// MARK: - AppEncoder
class AppEncoder : JSONEncoder {
    
    override init() {
        super.init()
        self.dateEncodingStrategy = .custom({ (date, encoder) in
            var container = encoder.singleValueContainer()
            try? container.encode(date.timeIntervalSince1970)
        })
    }
    
    func encodeAndGetDict<T>(_ value: T) throws -> [String: Any]? where T: Encodable {
        let encodedData = try self.encode(value)
        return try JSONSerialization.jsonObject(with: encodedData, options: []) as? [String: Any]
    }
    
    func encodeAndGetArray<T>(_ value: T) throws -> [[String: Any]]? where T: Encodable {
        let encodedData = try self.encode(value)
        return try JSONSerialization.jsonObject(with: encodedData, options: []) as? [[String: Any]]
    }
}

// MARK: - AppDecoder
class AppDecoder : JSONDecoder {
    
    override init() {
        super.init()
        self.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateTimeInterval = try container.decode(TimeInterval.self)
            return Date(timeIntervalSince1970: dateTimeInterval)
        })
    }
}
