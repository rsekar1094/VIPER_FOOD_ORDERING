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
    
    internal lazy var foodFilterView : FoodFilterView = {
        let view = FoodFilterView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.filterTypes = presenter.getAllowedFilterTypes()
        view.filterDelegate = self
        view.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return view
    }()
    
    // MARK: - Properties
    weak var delegate : ParentPageControlProtocol?
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(foodView)
        self.view.addSubview(foodFilterView)
    
        NSLayoutConstraint.activate([
            foodFilterView.topAnchor.constraint(equalTo: self.view.topAnchor),
            foodFilterView.heightAnchor.constraint(equalToConstant: 35),
            foodFilterView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            foodFilterView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            
            foodView.topAnchor.constraint(equalTo: self.foodFilterView.bottomAnchor,constant: 10),
            foodView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            foodView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.foodView.collectionViewLayout.invalidateLayout()
        }, completion: { _ in
            self.foodView.reloadData()
        })
    }
    
}

// MARK: - FoodListDelegate
extension FoodListViewController : FoodListDelegate {
    
    func didSelect(food : Food) {
        
    }
    
    func addToCart(food : Food) {
        presenter.addFoodToCart.onNext(food)
        self.foodView.addedFoodInToCart(food : food,totalItemInCart: presenter.getFoodCartCount(food : food))
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

// MARK: - FoodFilterDelegate
extension FoodListViewController : FoodFilterDelegate {
    func doFilterFood(with filter: String?) {
        self.presenter.foodFilter.onNext(filter)
    }
}
