//
//  UIViewController+Extensio.swift
//  VIPHER
//
//  Created by Rajasekar on 20/07/21.
//

import UIKit

extension UIViewController {
    
    //to show alert message
    func showAlert(title : String,
                   message : String,
                   okTitle : String = NSLocalizedString("OK", comment: ""),
                   cancelTitle : String? = nil,
                   okAction : (()->Void)? = nil,
                   cancelAction : (()->Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
     
        let okAction = UIAlertAction(title: okTitle, style: .default, handler: { (action) in
            okAction?()
        })
        alert.addAction(okAction)
        
        if let cancelTitel = cancelTitle {
            let cancel = UIAlertAction(title: cancelTitel, style: .cancel, handler: { (action) in
                cancelAction?()
            })
            cancel.setValue(UIColor.red, forKey: "titleTextColor")
            alert.addAction(cancel)
        }
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = .any
        }
        
        self.present(alert, animated: true, completion: nil)
    }
}
