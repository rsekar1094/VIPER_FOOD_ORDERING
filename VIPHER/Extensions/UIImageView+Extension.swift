//
//  UIImage+Extension.swift
//  VIPHER
//
//  Created by Rajasekar on 20/07/21.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    func setImage(url : URL?,placeholder : UIImage? = nil) {
        guard let url = url else {
            self.image = placeholder
            return
        }
        
        self.kf.indicatorType = .activity
        self.kf.indicator?.view.tintColor = UIColor.theme
        self.kf.setImage(with: ImageResource(downloadURL: url))
    }
}
