//
//  HomePresentor.swift
//  VIPHER
//
//  Created by Rajasekar on 19/07/21.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - HomePresenterDependencies
typealias HomePresenterDependencies = (
    interactor: HomeInteractor,
    router: HomeRouterOutput
)

// MARK: - HomePresenterInput
protocol HomePresenterInput : PresenterableInput {
    var didSelectBannerTrigger: PublishSubject<Banner> { get }
}

// MARK: - HomePresenterOutput
protocol HomePresenterOutput : PresenterableOutput {
    var homeDataResponse : BehaviorRelay<Result<HomeData,Error>> { get }
}


// MARK: - HomePresenter
final class HomePresenter : Presenterable,HomePresenterInput,HomePresenterOutput {
    
    // MARK: - Properties
    var inputs : HomePresenter { return self }
    var outputs : HomePresenter  { return self }
    private let disposeBag = DisposeBag()
    private let dependencies: HomePresenterDependencies
    
    // Outputs
    let homeDataResponse = BehaviorRelay<Result<HomeData,Error>>(value: .success(HomeData()))
    let isLoading: Observable<Bool>
    
    // Inputs
    let viewDidLoadTrigger = PublishSubject<Void>()
    let viewDidAppearTrigger = PublishSubject<Void>()
    let didSelectBannerTrigger = PublishSubject<Banner>()
    
    
    // MARK: - Initializers
    init(dependencies : HomePresenterDependencies) {
        self.dependencies = dependencies
        self.isLoading = dependencies.interactor.isHomeDataWaitingForResponse
        subscribe()
    }
    
    
    // MARK: - Subscriptions
    private func subscribe() {
        viewDidLoadTrigger.asObservable()
            .subscribe(onNext :  { [weak self] in
                self?.dependencies.interactor.requestHomeData()
            })
            .disposed(by: disposeBag)
        
        didSelectBannerTrigger.asObserver()
            .subscribe(onNext: { [weak self] banner in
                self?.dependencies.router.openBanner(banner: banner)
            }).disposed(by: disposeBag)
        
        
        ///Listen for the home data from interactor
        dependencies.interactor.homeDataResponse
            .subscribe(onNext: { [weak self] data in
                self?.homeDataResponse.accept(data)
            }).disposed(by: disposeBag)
    }
}
