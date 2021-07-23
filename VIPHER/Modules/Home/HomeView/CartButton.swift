//
//  CartButton.swift
//  Vipher
//
//  Created by Rajasekar on 23/07/21.
//

import UIKit

// MARK: - CartButton
class CartButton : UIButton {
    
    // MARK: - Properties
    var totalItem : Int = 0 {
        didSet {
            badgeLayer.isHidden = totalItem <= 0
            textLayer.string = "\(totalItem)"
        }
    }
    
    private let badgeLayer : CAShapeLayer
    private let textLayer : CATextLayer
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        badgeLayer = CAShapeLayer()
        textLayer = CATextLayer()
        super.init(frame: frame)
        
        self.layer.addSublayer(badgeLayer)
        badgeLayer.addSublayer(textLayer)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle methods
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = self.frame.size.height / 2
        
        let badgeRect : CGRect = CGRect(x: frame.width - 15, y: -4, width: 20, height: 20)
        textLayer.frame = badgeRect
        badgeLayer.path = UIBezierPath(roundedRect: badgeRect, cornerRadius: 10).cgPath
    }
    
    // MARK: - UI Setup
    private func setUp() {
        self.backgroundColor = .defaultBackground
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
        self.setImage(UIImage(systemName: "cart",withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)),
                      for: .normal)
        self.tintColor = .theme
        
        badgeLayer.fillColor = UIColor.red.cgColor
        badgeLayer.strokeColor = UIColor.red.cgColor
    
        textLayer.fontSize = 15
        textLayer.foregroundColor = UIColor.white.cgColor
        textLayer.alignmentMode = .center
    }
}
