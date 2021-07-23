//
//  CartViewController.swift
//  Vipher
//
//  Created by Rajasekar on 21/07/21.
//

import UIKit

// MARK: - CartViewController
class CartViewController : BaseViewController<CartPresenter> {
    
    private var tableView : UITableView { return self.view as! UITableView }
    private var cartItems : [CartItem] = []
    
    override func loadView() {
        self.view = UITableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(CartItemRowView.self)
        self.tableView.register(CartTotalRowView.self)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        
        presenter.cartItems.subscribe(onNext: { response in
            switch response {
            case .success(let items):
                self.cartItems = items
                self.tableView.reloadData()
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
    
    @objc
    private func didPressDelete(_ button : UIButton) {
        guard let indexPath = self.tableView.indexPath(for: button) else {
            return
        }
        
        self.presenter.delete(cartItem: cartItems[indexPath.item])
    }
}

// MARK: - Delegate + DataSource
extension CartViewController : UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if cartItems.isEmpty {
            let infoLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 500))
            infoLabel.text = NSLocalizedString("No Items present in your cart", comment: "")
            infoLabel.textColor = .defaultTextColor
            infoLabel.numberOfLines = 0
            infoLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
            infoLabel.textAlignment = .center
            self.tableView.backgroundView = infoLabel
            return 1
        } else {
            self.tableView.backgroundView = nil
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return cartItems.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeue(CartItemRowView.self,for: indexPath)
            cell.cartItem = cartItems[indexPath.item]
            cell.deleteButton.addTarget(self, action: #selector(didPressDelete(_:)), for: .touchUpInside)
            return cell
        } else {
            let cell = tableView.dequeue(CartTotalRowView.self,for: indexPath)
            cell.totalCartAmount = cartItems.map { $0.food.amount * $0.quantity }.reduce(0,+)
            return cell
        }
    }
    
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
