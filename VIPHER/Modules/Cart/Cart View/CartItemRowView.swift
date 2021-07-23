//
//  CartItemRowView.swift
//  Vipher
//
//  Created by Rajasekar on 21/07/21.
//

import UIKit

// MARK: - CartItemRowView
class CartItemRowView : UITableViewCell {
    
    // MARK: - Views
    private lazy var cartItemImageView : UIImageView = {
       let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var cartItemInfoLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .defaultTextColor
        label.numberOfLines = 0
        label.setContentHuggingPriority(UILayoutPriority(750), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(750), for: .horizontal)
        return label
    }()
    
    private lazy var amountLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .defaultTextColor
        label.setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        return label
    }()
    
    internal lazy var deleteButton : UIButton = {
        let deleteButton = UIButton()
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        deleteButton.tintColor = .defaultTextColor
        deleteButton.layer.cornerRadius = 15
        deleteButton.layer.masksToBounds = true
        deleteButton.backgroundColor = .lightGray.withAlphaComponent(0.4)
        return deleteButton
    }()
    
    // MARK: - Properties
    var cartItem : CartItem? {
        didSet {
            configure()
        }
    }
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        deleteButton.layer.cornerRadius = 15
    }
    
    // MARK: - UI Setup
    private func setUp() {
        self.selectionStyle = .none
        self.contentView.addSubview(cartItemImageView)
        self.contentView.addSubview(cartItemInfoLabel)
        self.contentView.addSubview(amountLabel)
        self.contentView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            cartItemImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,constant: 20),
            cartItemImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor,constant: 10),
            cartItemImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor,constant: -10),
            cartItemImageView.widthAnchor.constraint(equalToConstant: 50),
            cartItemImageView.heightAnchor.constraint(equalToConstant: 50),
            
            cartItemInfoLabel.centerYAnchor.constraint(equalTo: self.cartItemImageView.centerYAnchor),
            cartItemInfoLabel.leadingAnchor.constraint(equalTo: self.cartItemImageView.trailingAnchor,constant: 10),
            
            amountLabel.centerYAnchor.constraint(equalTo: self.cartItemImageView.centerYAnchor),
            amountLabel.leadingAnchor.constraint(greaterThanOrEqualTo : self.cartItemInfoLabel.trailingAnchor,constant: 20),
            amountLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -15),
            
            deleteButton.centerYAnchor.constraint(equalTo: cartItemImageView.centerYAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,constant: -20),
            deleteButton.widthAnchor.constraint(equalToConstant: 30),
            deleteButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    private func configure() {
        guard let cartItem = self.cartItem else {
            cartItemImageView.image = nil
            return
        }
        
        cartItemImageView.setImage(url: cartItem.food.imageUrl)
        cartItemInfoLabel.text = "\(cartItem.food.name) - \(cartItem.food.amount) usd × \(cartItem.quantity)"
        amountLabel.text = "\(cartItem.food.amount * cartItem.quantity) usd"
    }
    
    // MARK: - Life cycle methods
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.cartItem = nil
    }
}



// MARK: - CartTotalRowView
class CartTotalRowView : UITableViewCell {
    
    // MARK: - Views
    private lazy var totalLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .defaultTextColor
        label.text = NSLocalizedString("Total", comment: "")
        return label
    }()
    
    private lazy var totalAmountValue : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .defaultTextColor
        return label
    }()
    
    // MARK: - Properties
    var totalCartAmount : Int = 0 {
        didSet {
            totalAmountValue.text = "\(totalCartAmount) usd"
        }
    }
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setUp() {
        self.selectionStyle = .none
        
        self.contentView.addSubview(totalLabel)
        self.contentView.addSubview(totalAmountValue)
   
        NSLayoutConstraint.activate([
            totalLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,constant: 20),
            totalLabel.centerYAnchor.constraint(equalTo: self.totalAmountValue.centerYAnchor),
            
            totalAmountValue.topAnchor.constraint(equalTo: self.contentView.topAnchor,constant: 10),
            totalAmountValue.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor,constant: -10),
            totalAmountValue.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,constant: -50)
        ])
    }
}
