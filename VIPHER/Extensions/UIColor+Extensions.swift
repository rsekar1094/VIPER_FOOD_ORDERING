//
//  UIColor+Extensions.swift
//  VIPHER
//
//  Created by Rajasekar on 19/07/21.
//

import Foundation
import UIKit

// MARK: - App Colors
extension UIColor {
    
    public static var theme : UIColor { return UIColor(named : "AccentColor")! }
    
    public static var defaultTextColor : UIColor { return UIColor.init(named: "defaultText")! }
    
    public static var cardColor : UIColor { return UIColor.init(named: "cardColor")! }
    
    public static var defaultBackground : UIColor { return UIColor.init(named: "defaultBackground")! }
}


// MARK: - Initializers
extension UIColor {
    convenience init(hexString: String) {
        var hex = hexString.hasPrefix("#")
            ? String(hexString.dropFirst())
            : hexString
        guard hex.count == 3 || hex.count == 6
            else {
                self.init(white: 1.0, alpha: 0.0)
                return
        }
        if hex.count == 3 {
            for (index, char) in hex.enumerated() {
                hex.insert(char, at: hex.index(hex.startIndex, offsetBy: index * 2))
            }
        }
        
        guard let intCode = Int(hex, radix: 16) else {
            self.init(white: 1.0, alpha: 0.0)
            return
        }
        
        self.init(
            red:   CGFloat((intCode >> 16) & 0xFF) / 255.0,
            green: CGFloat((intCode >> 8) & 0xFF) / 255.0,
            blue:  CGFloat((intCode) & 0xFF) / 255.0, alpha: 1.0)
    }
}
