//
//  Food.swift
//  VIPHER
//
//  Created by Rajasekar on 19/07/21.
//

import Foundation
import ObjectMapper

// MARK: - Food
struct Food : Hashable {
    fileprivate(set) var id : String
    
    fileprivate(set) var name : String
    fileprivate(set) var description : String
    fileprivate(set) var info : String
    fileprivate(set) var imageUrl : URL
    
    fileprivate(set) var hasNonVeg : Bool
    fileprivate(set) var type : String
    fileprivate(set) var subTypes : [String]
    
    fileprivate(set) var amount : Int ///in usd
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Food + ObjectMapper
extension Food: ImmutableMappable {
    init(map: Map) throws {
        self.id = try map.value("id")
        self.name = try map.value("name")
        self.description = try map.value("description")
        self.info = try map.value("info")
        self.hasNonVeg = try map.value("hasNonVeg")
        self.subTypes = try map.value("subTypes")
        self.amount = try map.value("amount")
        self.type = try map.value("type")
        
        let imageUrl : String = try map.value("imageUrl")
        self.imageUrl = URL(string: imageUrl)!
    }
    
    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.name <- map["name"]
        self.description <- map["description"]
        self.info <- map["info"]
        
        self.hasNonVeg <- map["hasNonVeg"]
        self.amount <- map["amount"]
        self.imageUrl <- (map["imageUrl"],URLTransformType())
        self.type <- map["type"]
        
        self.subTypes <- map["subTypes"]
    }
}


class URLTransformType : TransformType {
    func transformToJSON(_ value: URL?) -> String? {
        return value?.absoluteString
    }
    
    func transformFromJSON(_ value: Any?) -> URL? {
        guard let string = value as? String else {
            return nil
        }
        
        return  URL(string: string)
    }
}

class MapperTransformType<T : ImmutableMappable> : TransformType {
    
    func transformToJSON(_ value: T?) -> [String:Any]? {
        return value?.toJSON()
    }
    
    func transformFromJSON(_ value: Any?) -> T? {
        guard let string = value as? [String:Any] else {
            return nil
        }
        
        return try? T(JSON: string)
    }
}
