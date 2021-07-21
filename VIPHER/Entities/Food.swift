//
//  Food.swift
//  VIPHER
//
//  Created by Rajasekar on 19/07/21.
//

import Foundation
import ObjectMapper

// MARK: - Food
struct Food {
    let id : String
    
    let name : String
    let description : String
    let info : String
    let imageUrl : URL
    
    let hasNonVeg : Bool
    let type : String
    let subTypes : [String]
    
    let amount : Int ///in usd
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
}
