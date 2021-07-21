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
    
    private let foodType : FoodType
    
    // MARK: - Initialziers
    init(foodType : FoodType) {
        self.foodType = foodType
        
        publishablefoodList = PublishRelay<Result<[Food],Error>>()
        foodListResponse = publishablefoodList.asObservable()
        
        publishableisFoodDataWaitingForResponse = PublishRelay<Bool>()
        isFoodDataWaitingForFoodListResponse = publishableisFoodDataWaitingForResponse.asObservable()
    }
    
    // MARK: - API
    public func requestFoodList() {
        publishableisFoodDataWaitingForResponse.accept(true)
        NetworkManager.shared.provider.rx.request(.food(foodType.id), callbackQueue: nil).subscribe { event in
            switch event {
            case let .success(response):
                do {
                    let data = try Mapper<Food>().mapArray(JSONString : JsonHandler.jsonStringFromData(response.data))
                    self.publishablefoodList.accept(.success(data))
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
