//
//  FoodListPresenter.swift
//  VIPHER
//
//  Created by Rajasekar on 20/07/21.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - FoodListPresenterDependencies
typealias FoodListPresenterDependencies = (
    interactor: FoodListInteractor,
    router: FoodListRouterOutput
)

// MARK: - FoodListPresenterInput
protocol FoodListPresenterInput : PresenterableInput {
    var addFoodToCart : PublishSubject<Food> { get }
    var foodFilter : PublishSubject<String?> { get }
}

// MARK: - FoodListPresenterOutput
protocol FoodListPresenterOutput : PresenterableOutput {
    var foodListResponse : BehaviorRelay<Result<[Food],Error>> { get }
}

// MARK: - FoodListPresenter
final class FoodListPresenter : Presenterable,FoodListPresenterInput,FoodListPresenterOutput {

    // MARK: - Properties
    
    var inputs : FoodListPresenter { return self }
    var outputs : FoodListPresenter  { return self }
    
    // Outputs
    let foodListResponse = BehaviorRelay<Result<[Food],Error>>(value: .success([]))
    let isLoading: Observable<Bool>
    
    // Inputs
    let viewDidLoadTrigger = PublishSubject<Void>()
    let viewDidAppearTrigger = PublishSubject<Void>()
    let addFoodToCart = PublishSubject<Food>()
    let foodFilter = PublishSubject<String?>()
    
    
    private let disposeBag = DisposeBag()
    private let dependencies: FoodListPresenterDependencies
    
    // MARK: - Initializers
    init(dependencies : FoodListPresenterDependencies) {
        self.dependencies = dependencies
        self.isLoading = dependencies.interactor.isFoodDataWaitingForFoodListResponse
        
        subscribe()
    }
    
    public func getFoodCartCount(food : Food) -> Int {
        return dependencies.interactor.getFoodCartCount(food: food)
    }
    
    public func getAllowedFilterTypes() -> [String] {
        return dependencies.interactor.getAllowedFilterTypes()
    }

    // MARK: - Subscription
    private func subscribe() {
        viewDidAppearTrigger.asObservable()
            .subscribe(onNext :  { [weak self] in
                self?.dependencies.interactor.requestFoodList()
            })
            .disposed(by: disposeBag)
        
        dependencies.interactor.foodListResponse
            .subscribe(onNext: { [weak self] data in
                self?.foodListResponse.accept(data)
            }).disposed(by: disposeBag)
        
        addFoodToCart.subscribe(onNext:{ [weak self] food in
            self?.dependencies.interactor.add(food: food)
        }).disposed(by: self.disposeBag)
        
        foodFilter.subscribe(onNext:{ [weak self] filter in
            self?.dependencies.interactor.filterFoods(with: filter)
        }).disposed(by: self.disposeBag)
    }
}
