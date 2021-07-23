//
//  CartPresenter.swift
//  Vipher
//
//  Created by Rajasekar on 21/07/21.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - CartPresenterDependencies
typealias CartPresenterDependencies = (
    interactor: CartInteractor,
    router: CartRouterOutput
)

// MARK: - CartPresenterInput
protocol CartPresenterInput : PresenterableInput {
    
}

// MARK: - CartPresenterOutput
protocol CartPresenterOutput : PresenterableOutput {
    var cartItems : BehaviorRelay<Result<[CartItem],Error>> { get }
}

// MARK: - CartPresenter
final class CartPresenter : Presenterable,CartPresenterInput,CartPresenterOutput {

    // MARK: - Properties
    
    var inputs : CartPresenter { return self }
    var outputs : CartPresenter  { return self }
    
    // Outputs
    let cartItems = BehaviorRelay<Result<[CartItem],Error>>(value: .success([]))
    let isLoading: Observable<Bool>
    
    // Inputs
    let viewDidLoadTrigger = PublishSubject<Void>()
    let viewDidAppearTrigger = PublishSubject<Void>()
    
    
    private let disposeBag = DisposeBag()
    private let dependencies: CartPresenterDependencies
    
    // MARK: - Initializers
    init(dependencies : CartPresenterDependencies) {
        self.dependencies = dependencies
        self.isLoading = dependencies.interactor.isFoodDataWaitingForCartResponse
        
        subscribe()
    }
    
    public func delete(cartItem : CartItem) {
        dependencies.interactor.delete(cartItem: cartItem)
    }
    
    // MARK: - Subscription
    private func subscribe() {
        viewDidLoadTrigger.subscribe(onNext: { [weak self] in
            self?.dependencies.interactor.getCartItems()
            self?.dependencies.router.assignTitle(NSLocalizedString("My Cart", comment: ""))
        }).disposed(by: self.disposeBag)
        
        dependencies.interactor.cartResponse
            .subscribe(onNext: { [weak self] data in
                self?.cartItems.accept(data)
            }).disposed(by: disposeBag)
    }
}
