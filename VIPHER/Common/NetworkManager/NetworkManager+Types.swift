//
//  NetworkManager+Types.swift
//  VIPHER
//
//  Created by Rajasekar on 19/07/21.
//

import Foundation
import Moya

// MARK: - NetworkRequestType
public enum NetworkRequestType {
    case home
    case food(String)
}

extension NetworkRequestType : TargetType {
    
    public var baseURL: URL { return URL(string: "https://api.xyz.com")! }
    
    public var path: String {
        switch self {
        case .home:
            return "/home"
        case .food(let type):
            return "/food?type=\(type)"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var task: Task {
        return .requestPlain
    }
    
    public var validationType: ValidationType {
        return .none
    }
    
    public var sampleData: Data {
        let fileName : String
        switch self {
        case .home:
            fileName = "SampleHomeData"
        case .food(let type):
            switch type.lowercased() {
            case "pizza":
                fileName = "SamplePizzaFoodListData"
            case "drinks":
                fileName = "SampleDrinksFoodListData"
            case "sushi":
                fileName = "SampleSushiFoodListData"
            default:
                fileName = ""
            }
        }
        
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                return try Data(contentsOf: url)
            } catch {
                return "Error".data(using: String.Encoding.utf8)!
            }
        } else {
            return "Error".data(using: String.Encoding.utf8)!
        }
    }
    
    public var headers: [String: String]? {
        return nil
    }
}
