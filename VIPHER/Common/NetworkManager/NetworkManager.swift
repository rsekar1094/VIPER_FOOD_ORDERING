//
//  Api.swift
//  VIPHER
//
//  Created by Rajasekar on 19/07/21.
//

import Foundation
import Moya

struct NetworkManager {
    
    @Inject var provider : MoyaProvider<NetworkRequestType>

    public static let shared = NetworkManager()
    
    private init() {
        
    }
}
