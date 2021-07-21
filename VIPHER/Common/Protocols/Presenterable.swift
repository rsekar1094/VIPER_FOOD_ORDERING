//
//  Presenterable.swift
//  VIPHER
//
//  Created by Rajasekar on 19/07/21.
//


import Foundation
import RxSwift

// MARK: - Presenterable
protocol Presenterable : AnyObject {
    associatedtype Input : PresenterableInput
    associatedtype Output : PresenterableOutput
    
    var inputs : Input { get }
    var outputs : Output  { get }
}

// MARK: - PresenterableInput
protocol PresenterableInput : AnyObject {
    var viewDidLoadTrigger: PublishSubject<Void> { get }
    var viewDidAppearTrigger: PublishSubject<Void> { get }
    
}


// MARK: - PresenterableOutput
protocol PresenterableOutput : AnyObject {
    var isLoading: Observable<Bool> { get }
}
