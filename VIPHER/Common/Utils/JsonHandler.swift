//
//  JSONHandler.swift
//  VIPHER
//
//  Created by Rajasekar on 19/07/21.
//

import Foundation

/// Helper class to convert json data
struct JsonHandler {
    
    /// Return a dictionary from the data
    ///
    /// - Parameter dictionaryAsData: data object to convert
    /// - Returns: dictonary of string to string
    static func dictionaryFromData(_ dictionaryAsData: Data?) -> [String: Any]? {
        guard let dictionaryAsData = dictionaryAsData else {
            return nil
        }
        if let decoded = try? JSONSerialization.jsonObject(with: dictionaryAsData, options: []), let dictFromJSON = decoded as? [String: Any] {
            return dictFromJSON
        } else {
            return nil
        }
    }

    /// Return a data from json dictionary
    ///
    /// - Parameter dictionary: Dictionary representation of json
    /// - Returns: data object with the json
    static func dataFromDictionary(_ dictionary: [String: Any]?) -> Data? {
        guard let dictionary = dictionary else {
            return nil
        }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) {
            return jsonData
        } else {
            return nil
        }
    }
    
    static func jsonStringFromData(_ data: Data) -> String {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return String(data: prettyData, encoding: .utf8) ?? String(data: data, encoding: .utf8) ?? ""
        } catch {
            return String(data: data, encoding: .utf8) ?? ""
        }
    }
    
    static func jsonString(_ data: Any) -> String? {
        do {
            let prettyData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            return String(data: prettyData, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
