//
//  NSObject+Extension.swift
//  Vipher
//
//  Created by Rajasekar on 24/07/21.
//

import Foundation
extension NSObject {
    var instanceId : String {
       return String(UInt(bitPattern: ObjectIdentifier(self)))
    }
}
