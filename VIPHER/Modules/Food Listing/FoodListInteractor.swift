//
//  FoodListInteractor.swift
//  VIPHER
//
//  Created by Rajasekar on 20/07/21.
//

import Foundation
import RxSwift
import RxCocoa
import ObjectMapper

// MARK: - FoodListInteractor
final class FoodListInteractor : Interactorable {
    
    // MARK: - Properties
    let foodListResponse : Observable<Result<[Food],Error>>
    private let publishablefoodList : PublishRelay<Result<[Food],Error>>
    
    let isFoodDataWaitingForFoodListResponse : Observable<Bool>
    private var publishableisFoodDataWaitingForResponse : PublishRelay<Bool>
    
    private let disposeBag = DisposeBag()
    
    private var foodItems : [Food] = []
    
    private let foodType : FoodType
    private var currentFilterType : String?
    
    // MARK: - Initialziers
    init(foodType : FoodType) {
        self.foodType = foodType
        
        publishablefoodList = PublishRelay<Result<[Food],Error>>()
        foodListResponse = publishablefoodList.asObservable()
        
        publishableisFoodDataWaitingForResponse = PublishRelay<Bool>()
        isFoodDataWaitingForFoodListResponse = publishableisFoodDataWaitingForResponse.asObservable()
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
    
    public func getFoodCartCount(food : Food) -> Int {
        return CartDataSource.shared.items.first(where: { $0.food.id == food.id })?.quantity ?? 0
    }
    
    public func getAllowedFilterTypes() -> [String] {
        return foodType.subTypes
    }
    
    public func filterFoods(with filter : String?) {
        let items : [Food]
        if let filter = filter {
            items = foodItems.filter { $0.subTypes.contains(filter) }
        } else {
            items = foodItems
        }
        self.currentFilterType = filter
        self.publishablefoodList.accept(.success(items))
    }
    
    // MARK: - API
    public func requestFoodList() {
        publishableisFoodDataWaitingForResponse.accept(true)
        NetworkManager.shared.provider.rx.request(.food(foodType.id), callbackQueue: nil).subscribe { event in
            switch event {
            case let .success(response):
                do {
                    let data = try Mapper<Food>().mapArray(JSONString : JsonHandler.jsonStringFromData(response.data))
                    self.foodItems = data
                    self.filterFoods(with : self.currentFilterType)
                } catch let error {
                    self.publishablefoodList.accept(.failure(error))
                }
            case let .error(error):
                self.publishablefoodList.accept(.failure(error))
            }
            
            self.publishableisFoodDataWaitingForResponse.accept(false)
        }.disposed(by: disposeBag)
    }
}
