//
//  CartInteractor.swift
//  Vipher
//
//  Created by Rajasekar on 21/07/21.
//

import Foundation
import RxSwift
import RxCocoa
import ObjectMapper

// MARK: - CartInteractor
class CartInteractor : Interactorable {
    
    // MARK: - Properties
    let cartResponse : Observable<Result<[CartItem],Error>>
    private var publishableCartResponse : PublishRelay<Result<[CartItem],Error>>
    
    let isFoodDataWaitingForCartResponse : Observable<Bool>
    private var publishableisCartDataWaitingForResponse : PublishRelay<Bool>
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Initialziers
    init() {
        publishableCartResponse = PublishRelay<Result<[CartItem],Error>>()
        cartResponse = publishableCartResponse.asObservable()
        
        publishableisCartDataWaitingForResponse = PublishRelay<Bool>()
        isFoodDataWaitingForCartResponse = publishableisCartDataWaitingForResponse.asObservable()
        
        CartDataSource.shared.cartResponse.subscribe(onNext: { cartResponse in
            self.publishableCartResponse.accept(cartResponse)
        }).disposed(by: self.disposeBag)
    }
    
    public func delete(cartItem : CartItem) {
        if let index = CartDataSource.shared.items.firstIndex(where: { $0.food.id == cartItem.food.id }) {
            CartDataSource.shared.items.remove(at: index)
        } 
    }
    
    public func add(food : Food) {
        if let index = CartDataSource.shared.items.firstIndex(where: { $0.food.id == food.id }) {
            var item = CartDataSource.shared.items[index]
            item.quantity += 1
            CartDataSource.shared.items[index] = item
        } else {
            CartDataSource.shared.items.append(CartItem(food: food, quantity: 1))
        }
    }
    
    public func getCartItems() {
        self.publishableCartResponse.accept(.success(CartDataSource.shared.items))
    }
}
