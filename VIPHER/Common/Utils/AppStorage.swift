//
//  AppStorage.swift
//  VIPHER
//
//  Created by Rajasekar on 19/07/21.
//

import Foundation

// MARK: - AppStorage
class AppStorage {
    
    #if DEBUG
    public static var defaults = UserDefaults(suiteName: "group.rsekar.VIPHER.dev") ?? UserDefaults.standard
    #else
    public static var defaults = UserDefaults(suiteName: "group.rsekar.VIPHER.release") ?? UserDefaults.standard
    #endif
    
    public static func store(suite : String , key : String , value : Any?){
        defaults.set(value, forKey: suite+key)
        defaults.synchronize()
    }
    
    public static func getDict(suite : String , key : String) -> [String:Any]? {
        return defaults.dictionary(forKey: suite+key)
    }
    
    public static func remove(suite : String , key : String){
        defaults.removeObject(forKey: suite+key)
        defaults.synchronize()
    }
}
