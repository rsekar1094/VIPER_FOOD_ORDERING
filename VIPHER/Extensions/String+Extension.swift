//
//  String+Extension.swift
//  VIPHER
//
//  Created by Rajasekar on 20/07/21.
//

import Foundation
import UIKit

extension String {
    
    func width(for font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func height(for width: CGFloat, font: UIFont) -> CGFloat {
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let actualSize = self.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: font], context: nil)
        return actualSize.height
    }
}


extension NSAttributedString {
    
    internal convenience init?(html: String) {
        guard let data = html.data(using: String.Encoding.utf16, allowLossyConversion: false) else {
            return nil
        }
        
        guard let attributedString = try?  NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) else {
            return nil
        }
        
        self.init(attributedString: attributedString)
    }
    
    internal convenience init(image : UIImage,
                               imageSize : CGSize,
                               imageTintColor : UIColor,
                               font : UIFont) {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image.withTintColor(imageTintColor)
        imageAttachment.bounds = CGRect(x: CGFloat(0), y: (font.capHeight - imageSize.height) / 2, width: imageSize.width, height: imageSize.height)
        self.init(attachment: imageAttachment)
    }
}
