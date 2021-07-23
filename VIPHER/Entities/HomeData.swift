//
//  LaunchInfo.swift
//  VIPHER
//
//  Created by Rajasekar on 19/07/21.
//

import Foundation
import ObjectMapper

// MARK: - HomeData
struct HomeData {
    fileprivate(set) var banners : [Banner]
    fileprivate(set) var foodTypes : [FoodType]
    
    init() {
        banners = []
        self.foodTypes = []
    }
}

// MARK: - Banner
struct Banner {
    fileprivate(set) var id : String
    fileprivate(set) var imageUrl : URL
    fileprivate(set) var actionUrl : URL?
}

// MARK: - FoodType
struct FoodType {
    fileprivate(set) var id : String
    fileprivate(set) var name : String
    fileprivate(set) var subTypes : [String]
}





// MARK: - HomeData + ObjectMapper
extension HomeData: ImmutableMappable {
    
    init(map: Map) throws {
        self.banners = try map.value("banners")
        self.foodTypes = try map.value("foodTypes")
    }
    
    mutating func mapping(map: Map) {
        self.banners <- map["banners"]
        self.foodTypes <- map["foodTypes"]
    }
}

// MARK: - Banner + ObjectMapper
extension Banner: ImmutableMappable {
    
    init(map: Map) throws {
        self.id = try map.value("id")
        
        let imageUrl : String = try map.value("imageUrl")
        self.imageUrl = URL(string: imageUrl)!
        
        if let actionUrl : String = try? map.value("actionUrl") {
            self.actionUrl = URL(string: actionUrl)
        } else {
            self.actionUrl = nil
        }
    }
    
    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.imageUrl <- (map["imageUrl"],URLTransformType())
        self.actionUrl <- (map["actionUrl"],URLTransformType())
    }
    
}

// MARK: - FoodType + ObjectMapper
extension FoodType: ImmutableMappable {
    
    init(map: Map) throws {
        self.id = try map.value("id")
        self.name = try map.value("name")
        self.subTypes = (try?  map.value("subTypes")) ?? []
    }
    
    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.name <- map["name"]
        self.subTypes <- map["subTypes"]
    }
    
}
