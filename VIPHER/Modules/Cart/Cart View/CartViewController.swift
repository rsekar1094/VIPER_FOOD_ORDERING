//
//  CartViewController.swift
//  Vipher
//
//  Created by Rajasekar on 21/07/21.
//

import UIKit

// MARK: - CartHeaderItem
enum CartHeaderItem: String,Hashable {
    case cartItem
    case total
}


// MARK: - CartViewController
class CartViewController : BaseViewController<CartPresenter> {
    
    // MARK: - Views
    private var tableView : UITableView { return self.view as! UITableView }
    
    // MARK: - Properties
    private var cartDataSource: UITableViewDiffableDataSource<CartHeaderItem, AnyHashable>!
    private var cartItems : [CartItem] = [] {
        didSet {
            reloadCart()
        }
    }
    
    // MARK: - Life cycle methods
    override func loadView() {
        self.view = UITableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
        
        presenter.cartItems.subscribe(onNext: { response in
            switch response {
            case .success(let items):
                self.cartItems = items
            case .failure(let error):
                self.showAlert(title: NSLocalizedString("Error!", comment: ""), message: error.localizedDescription)
            }
        }).disposed(by: self.disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Action
    @objc
    private func didPressDelete(_ button : UIButton) {
        guard let indexPath = self.tableView.indexPath(for: button) else {
            return
        }
        
        self.presenter.delete(cartItem: cartItems[indexPath.item])
    }
    
    
    // MARK: - Snapshot reload
    private func reloadCart() {
        var snapshot = NSDiffableDataSourceSnapshot<CartHeaderItem, AnyHashable>()
        if !cartItems.isEmpty {
            snapshot.appendSections([.cartItem,.total])
            snapshot.appendItems(self.cartItems, toSection: .cartItem)
            snapshot.appendItems([self.cartItems.map { $0.food.amount * $0.quantity }.reduce(0,+)],toSection: .total)
        }
        self.cartDataSource.apply(snapshot,animatingDifferences: true)
        
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        if cartItems.isEmpty {
            let infoLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 500))
            infoLabel.text = NSLocalizedString("No Items present in your cart", comment: "")
            infoLabel.textColor = .defaultTextColor
            infoLabel.numberOfLines = 0
            infoLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
            infoLabel.textAlignment = .center
            self.tableView.backgroundView = infoLabel
        } else {
            self.tableView.backgroundView = nil
        }
    }
    
    // MARK: - Setup
    private func setUp() {
        self.tableView.delegate = self
        self.tableView.register(CartItemRowView.self)
        self.tableView.register(CartTotalRowView.self)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        
        cartDataSource = UITableViewDiffableDataSource<CartHeaderItem, AnyHashable>(tableView: self.tableView,cellProvider: { [weak self] (tableView, indexPath, item) -> UITableViewCell?  in
            
            guard let `self` = self else {
                return nil
            }
            
            if let cartItem = item as? CartItem {
                let cell = tableView.dequeue(CartItemRowView.self,for: indexPath)
                cell.cartItem = cartItem
                cell.deleteButton.addTarget(self, action: #selector(self.didPressDelete(_:)), for: .touchUpInside)
                return cell
            } else if let amount = item as? Int {
                let cell = tableView.dequeue(CartTotalRowView.self,for: indexPath)
                cell.totalCartAmount = amount
                return cell
            } else {
                return nil
            }
            
        })
    }
}

// MARK: - Delegate + DataSource
extension CartViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            return UIView()
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 40
        } else {
            return .leastNormalMagnitude
        }
    }
}
