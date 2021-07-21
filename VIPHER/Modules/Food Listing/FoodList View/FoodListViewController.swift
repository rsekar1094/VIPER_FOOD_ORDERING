//
//  FoodListViewController.swift
//  VIPHER
//
//  Created by Rajasekar on 20/07/21.
//

import Foundation
import UIKit

// MARK: - FoodListViewController
class FoodListViewController : BaseViewController<FoodListPresenter> {
 
    // MARK: - Views
    internal lazy var foodView : FoodListView = {
        let foodView = FoodListView()
        foodView.translatesAutoresizingMaskIntoConstraints = false
        foodView.foodDelegate = self
        return foodView
    }()
    
    // MARK: - Properties
    weak var delegate : ParentPageControlProtocol?
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        self.view.addSubview(foodView)
        super.viewDidLoad()
    
        NSLayoutConstraint.activate([
            foodView.topAnchor.constraint(equalTo: self.view.topAnchor),
            foodView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            foodView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            foodView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        ///subscribe to food list response and reload the UI
        presenter.foodListResponse.subscribe(onNext: { response in
            switch response {
            case .success(let items):
                self.foodView.items = items
            case .failure(let error):
                self.showAlert(title: NSLocalizedString("Error!", comment: ""), message: error.localizedDescription)
            }
        }, onError: { error in
            self.showAlert(title: NSLocalizedString("Error!", comment: ""), message: error.localizedDescription)
        }).disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        delegate?.assignCurrentChildScrollView(self.foodView)
    }
    
}

// MARK: - FoodListDelegate
extension FoodListViewController : FoodListDelegate {
    
    func didSelect(food : Food) {
        print("didSelect \(food.id)")
    }
    
    func addToCart(food : Food) {
        print("addToCart \(food.id)")
    }
    
    func didFoodListScrolled() {
        self.delegate?.didChildScrollViewScrolled(self.foodView)
    }
    
    func didFoodListEndDragging(willDecelerate : Bool) {
        self.delegate?.didChildScrollViewEndDragging(self.foodView, willDecelerate: willDecelerate)
    }
    
    func didFoodListEndDecelerate() {
        self.delegate?.didChildScrollViewEndDecelerate(self.foodView)
    }
}
