//
//  Cart.swift
//  Vipher
//
//  Created by Rajasekar on 21/07/21.
//

import Foundation
import ObjectMapper

struct CartItem {
    fileprivate(set) var food : Food
    var quantity : Int
}



// MARK: - Food + ObjectMapper
extension CartItem: ImmutableMappable {
    init(map: Map) throws {
        self.food = try map.value("food")
        self.quantity = try map.value("quantity")
    }
    
    mutating func mapping(map: Map) {
        self.food <- (map["food"],MapperTransformType<Food>())
        self.quantity <- map["quantity"]
    }
}



import RxSwift
import RxCocoa

class CartDataSource {
    
    public static let shared = CartDataSource()
    
    private init() {
        let array = AppStorage.getStringArray(suite: "User", key: "Cart")
        self.items = array.map { try! Mapper<CartItem>().map(JSONString: $0) }
        
        publishableCartItem = PublishRelay<Result<[CartItem],Error>>()
        publishableCartItem.accept(.success(self.items))
        cartResponse = publishableCartItem.asObservable()
    }
    
    var items : [CartItem] = [] {
        didSet {
            publishableCartItem.accept(.success(items))
            
            AppStorage.store(suite: "User", key: "Cart", value: items.map { $0.toJSONString(prettyPrint: true) })
        }
    }
    
    let cartResponse : Observable<Result<[CartItem],Error>>
    private let publishableCartItem : PublishRelay<Result<[CartItem],Error>>
    
}
