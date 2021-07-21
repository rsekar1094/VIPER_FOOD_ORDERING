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
    let banners : [Banner]
    let foodTypes : [FoodType]
    
    init() {
        banners = []
        self.foodTypes = []
    }
}

// MARK: - Banner
struct Banner {
    let id : String
    let imageUrl : URL
    let actionUrl : URL?
}

// MARK: - FoodType
struct FoodType {
    let id : String
    let name : String
    let subTypes : [String]
}





// MARK: - HomeData + ObjectMapper
extension HomeData: ImmutableMappable {
    
    init(map: Map) throws {
        self.banners = try map.value("banners")
        self.foodTypes = try map.value("foodTypes")
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
    
}

// MARK: - FoodType + ObjectMapper
extension FoodType: ImmutableMappable {
    
    init(map: Map) throws {
        self.id = try map.value("id")
        self.name = try map.value("name")
        self.subTypes = (try?  map.value("subTypes")) ?? []
    }
    
}
