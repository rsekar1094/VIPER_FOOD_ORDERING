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
    
    
    private let disposeBag = DisposeBag()
    private let dependencies: FoodListPresenterDependencies
    
    // MARK: - Initializers
    init(dependencies : FoodListPresenterDependencies) {
        self.dependencies = dependencies
        self.isLoading = dependencies.interactor.isFoodDataWaitingForFoodListResponse
        
        subscribe()
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
    }
}
