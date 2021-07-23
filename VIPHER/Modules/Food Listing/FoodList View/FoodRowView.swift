//
//  FoodRowView.swift
//  VIPHER
//
//  Created by Rajasekar on 21/07/21.
//

import Foundation
import UIKit

// MARK: - FoodRowView
class FoodRowView : UICollectionViewCell {
    
    // MARK: - Static
    private static let imageHeight : CGFloat = 165
    private static let horziontalMargin : CGFloat = 20
    private static let titleTopMargin : CGFloat = 22
    private static let descriptionTopMargin : CGFloat = 0
    
    private static let actionButtonTopMargin : CGFloat = 15
    private static let actionButtonHeight : CGFloat = 50
    private static let actionButtonBottomMargin : CGFloat = 20
    
    private static let titleFont : UIFont = UIFont.systemFont(ofSize: 20,weight: .bold)
    private static let descriptionFont : UIFont = UIFont.systemFont(ofSize: 16,weight: .regular)
    
    ///Get prefer height for the given food by calculating the description,title and it's image
    public static func getPreferHeight(for food : Food,width : CGFloat) -> CGFloat {
        let contentWidth = width - (2 * horziontalMargin)
        let titleHeight = food.name.height(for: contentWidth, font: FoodRowView.titleFont)
        let descriptionHeight = food.description.height(for: contentWidth, font: FoodRowView.descriptionFont)
        
        let spacing = titleTopMargin + descriptionTopMargin + actionButtonTopMargin + actionButtonBottomMargin
        
        return imageHeight + titleHeight + descriptionHeight + actionButtonHeight + spacing
    }
    
    
    // MARK: - Views
    private var imageView : UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.backgroundColor = UIColor.theme
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }()
    
    private var titleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FoodRowView.titleFont
        label.textColor = .defaultTextColor
        label.numberOfLines = 0
        return label
    }()
    
    private var descriptionLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FoodRowView.descriptionFont
        label.textColor = .defaultTextColor
        label.numberOfLines = 0
        return label
    }()
    
    private var infoLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14,weight: .regular)
        label.textColor = .defaultTextColor.withAlphaComponent(0.8)
        return label
    }()
    
    internal var actionButton : AddToCartButton = {
        let actionButton = AddToCartButton()
        actionButton.isUserInteractionEnabled = true
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        return actionButton
    }()
    
    
    // MARK: - Properties
    var food : Food? {
        didSet {
            configure()
        }
    }
    
    // MARK: - Initialziers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setUp()
    }
    
    // MARK: - Life cycle methods
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        imageView.layer.cornerRadius = 10
        self.contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard let oldStyle = previousTraitCollection?.userInterfaceStyle,
              oldStyle != self.traitCollection.userInterfaceStyle else {
            return
        }
        
        ///Update the description text color whenever interface style changes
        DispatchQueue.main.async {
            self.updateDescription()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.food = nil
    }
    
    func addedInToCart(totalItemInCart : Int) {
        actionButton.update(itemPrice: food?.amount ?? 0, totalCount: totalItemInCart)
        actionButton.showInfo()
    }
}

// MARK: - FoodRowView + Utils
extension FoodRowView {
    
    private func configure() {
        guard let food = self.food else {
            self.imageView.image = nil
            self.actionButton.hideInfo()
            return
        }
        
        imageView.setImage(url: food.imageUrl)
        
        let title = NSMutableAttributedString(string: food.name,attributes: [.font : FoodRowView.titleFont,
                                                                             .foregroundColor : UIColor.defaultTextColor])
        if food.hasNonVeg {
            title.append(NSAttributedString(string: " ",attributes: [.font : FoodRowView.titleFont]))
            title.append(NSAttributedString(image: UIImage(named: "circle")!, imageSize: CGSize(width: 10, height: 10), imageTintColor: .red, font: FoodRowView.titleFont))
        }
        self.titleLabel.attributedText = title
        updateDescription()
        self.infoLabel.text = food.info
        self.actionButton.update(itemPrice: food.amount, totalCount: 0)
        self.actionButton.hideInfo()
    }
    
    private func updateDescription() {
        guard let food = self.food else {
            return
        }
        
        guard let descriptionString = NSAttributedString(html: food.description) else {
            return
        }
        
        let description = NSMutableAttributedString(attributedString: descriptionString)
        var additionalAttributes : [NSAttributedString.Key : Any] = [:]
        switch self.traitCollection.userInterfaceStyle {
        case .dark:
            additionalAttributes = [.font : FoodRowView.descriptionFont,.foregroundColor : UIColor.defaultTextColor]
        default:
            additionalAttributes = [.font : FoodRowView.descriptionFont]
        }
        
        description.addAttributes(additionalAttributes,range: NSRange.init(location: 0, length: description.length))
        self.descriptionLabel.attributedText = description
    }
    
    private func setUp() {
        self.contentView.isUserInteractionEnabled = true
        self.isUserInteractionEnabled = true
        
        self.contentView.backgroundColor = .cardColor
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(descriptionLabel)
        self.contentView.addSubview(infoLabel)
        self.contentView.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            imageView.heightAnchor.constraint(equalToConstant: FoodRowView.imageHeight),
            
            titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,constant: FoodRowView.horziontalMargin),
            titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,constant: -FoodRowView.horziontalMargin),
            titleLabel.topAnchor.constraint(equalTo: self.imageView.bottomAnchor,constant: FoodRowView.titleTopMargin),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor,constant: FoodRowView.descriptionTopMargin),
            
            infoLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            infoLabel.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor),
            
            actionButton.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            actionButton.topAnchor.constraint(greaterThanOrEqualTo : descriptionLabel.bottomAnchor,constant: FoodRowView.actionButtonTopMargin),
            actionButton.heightAnchor.constraint(equalToConstant: FoodRowView.actionButtonHeight),
            actionButton.widthAnchor.constraint(equalToConstant: 200),
            actionButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor,constant: -FoodRowView.actionButtonBottomMargin)
        ])
    }
}



// MARK: - AddToCartButton
class AddToCartButton  : UIButton {
    
    // MARK: - Properties
    private var stateChangeTimer : Timer?
    private var cartCountOfCurrentItem : Int = 0
    private var itemPrice : Int = 0
    private var isInfoVisible : Bool = false {
        didSet {
            configure()
        }
    }
    private let backgroundLayer : CAGradientLayer
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        backgroundLayer = CAGradientLayer()
        super.init(frame: frame)
        self.layer.addSublayer(backgroundLayer)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        backgroundLayer = CAGradientLayer()
        super.init(coder: coder)
        self.layer.addSublayer(backgroundLayer)
        setUp()
    }
    
    // MARK: - Life cycle methods
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = self.frame.size.height / 2
        self.backgroundLayer.frame = self.bounds
        backgroundLayer.cornerRadius = self.frame.size.height / 2
    }
    
    // MARK: - Configuration
    public func update(itemPrice : Int,totalCount : Int) {
        self.itemPrice = itemPrice
        self.cartCountOfCurrentItem = totalCount
        self.configure()
    }
    
    public func showInfo() {
        self.isInfoVisible = true
    }
    
    public func hideInfo() {
        self.isInfoVisible = false
    }

    // MARK: - UI Setup
    private func setUp() {
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16,weight: .medium)
        self.setTitleColor(.white, for: .normal)
        configure()
        self.backgroundColor = .clear
        
        backgroundLayer.colors = [UIColor.theme.cgColor,UIColor.theme.cgColor]
        backgroundLayer.locations = [1,1] as [NSNumber]
        backgroundLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        backgroundLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
    }
    
    private func configure() {
        if isInfoVisible {
            self.setTitle("added +\(cartCountOfCurrentItem)", for: .normal)
            self.updateBackgroundColor(from: UIColor.theme, to: UIColor.init(hexString: "#5eb64d"), fromLeft: true)
            
            stateChangeTimer?.invalidate()
            stateChangeTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false, block: { [weak self] timer in
                guard let `self` = self else {
                    timer.invalidate()
                    return
                }
                self.isInfoVisible = false
                timer.invalidate()
            })
        } else {
            self.updateBackgroundColor(from: UIColor.init(hexString: "#5eb64d"), to: .theme, fromLeft: false)
            self.setTitle("\(itemPrice) usd", for: .normal)
            stateChangeTimer?.invalidate()
        }
    }
    
    private func updateBackgroundColor(from : UIColor,to : UIColor,fromLeft : Bool) {
        let startLocations = fromLeft ? [0, 0] : [1,2]
        let endLocations = fromLeft ? [1, 2] : [0,0]
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.backgroundLayer.locations = [1,1]
            self.backgroundLayer.colors = [to.cgColor,to.cgColor]
        })
        
        let animationGroup = CAAnimationGroup()
        
        let colorAnimation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.colors))
        colorAnimation.fromValue = from.cgColor
        colorAnimation.toValue = to.cgColor
        colorAnimation.duration = 0.2
        
        let locationAnimation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        locationAnimation.fromValue = startLocations
        locationAnimation.toValue = endLocations
        locationAnimation.duration = 0.2
        
        animationGroup.animations = [colorAnimation,locationAnimation]
        
        backgroundLayer.removeAllAnimations()
        backgroundLayer.add(animationGroup, forKey: "loc")
        CATransaction.commit()
    }
}
