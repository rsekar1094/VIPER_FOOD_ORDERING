//
//  Resolver.swift
//  VIPHER
//
//  Created by Rajasekar on 19/07/21.
//

import Foundation

class Resolver{
  
    static let shared = Resolver()
    var factoryDict: [String: () -> Any] = [:]
    
    func add<T>(type: T.Type, _ factory: @escaping () -> T) {
        factoryDict[String(describing: type.self)] = factory
    }

    func resolve<T>(_ type: T.Type) -> T {
        let component: T = factoryDict[String(describing:T.self)]?() as! T
        return component
    }
}
