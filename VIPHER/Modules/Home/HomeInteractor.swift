//
//  HomeInteractor.swift
//  VIPHER
//
//  Created by Rajasekar on 19/07/21.
//

import Foundation
import RxSwift
import RxCocoa
import ObjectMapper

// MARK: - HomeInteractor
final class HomeInteractor : Interactorable {
    
    // MARK: - Properties
    let homeDataResponse : Observable<Result<HomeData,Error>>
    private let publishableHomeData : PublishRelay<Result<HomeData,Error>>
    
    let isHomeDataWaitingForResponse : Observable<Bool>
    private var publishableisHomeDataWaitingForResponse : PublishRelay<Bool>
    
    private let disposeBag = DisposeBag()
    
    
    // MARK: - Initializers
    init() {
        publishableHomeData = PublishRelay<Result<HomeData,Error>>()
        homeDataResponse = publishableHomeData.asObservable()
        
        publishableisHomeDataWaitingForResponse = PublishRelay<Bool>()
        isHomeDataWaitingForResponse = publishableisHomeDataWaitingForResponse.asObservable()
    }
    
    
    // MARK: - API
    public func requestHomeData() {
        publishableisHomeDataWaitingForResponse.accept(true)
        
        NetworkManager.shared.provider.rx.request(.home, callbackQueue: nil).subscribe { event in
            switch event {
            case let .success(response):
                do {
                    let data = try Mapper<HomeData>().map(JSON: JsonHandler.dictionaryFromData(response.data) ?? [:])
                    self.publishableHomeData.accept(.success(data))
                } catch let error {
                    self.publishableHomeData.accept(.failure(error))
                }
            case let .error(error):
                self.publishableHomeData.accept(.failure(error))
            }
            
            self.publishableisHomeDataWaitingForResponse.accept(false)
            
        }.disposed(by: disposeBag)
    }
    
}
