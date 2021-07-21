//
//  Inject.swift
//  VIPHER
//
//  Created by Rajasekar on 19/07/21.
//

import Foundation

// MARK: - Inject

///Used for the dependency injection
@propertyWrapper
struct Inject<T>{
    
    var component: T
    
    init(){
        self.component = Resolver.shared.resolve(T.self)
    }
    
    public var wrappedValue : T{
        get { return component}
        mutating set { component = newValue }
    }
    
}
