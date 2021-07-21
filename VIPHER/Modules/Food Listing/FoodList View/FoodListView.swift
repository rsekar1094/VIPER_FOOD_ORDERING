//
//  FoodListView.swift
//  VIPHER
//
//  Created by Rajasekar on 21/07/21.
//

import Foundation
import UIKit

// MARK: - FoodListDelegate
protocol FoodListDelegate : AnyObject {
    func didSelect(food : Food)
    func addToCart(food : Food)
    func didFoodListScrolled()
}

// MARK: - FoodListView
class FoodListView : UICollectionView {
    
    // MARK: - Properties
    weak var foodDelegate : FoodListDelegate?
    var items : [Food] = [] {
        didSet {
            self.reloadData()
        }
    }
    
    // MARK: - Initializers
    init() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.headerReferenceSize = .zero
        flowLayout.footerReferenceSize = .zero
        flowLayout.minimumLineSpacing = 20
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        
        super.init(frame: .zero, collectionViewLayout: flowLayout)
        
        self.delegate = self
        self.dataSource = self
        self.backgroundColor = .defaultBackground
        self.contentInset = UIEdgeInsets.zero
        
        self.register(FoodRowView.self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - DataSource + Delegate
extension FoodListView : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(FoodRowView.self, for: indexPath)
        cell.food = items[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = FoodRowView.getPreferHeight(for: items[indexPath.item], width: collectionView.frame.size.width)
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let spacing = flowLayout.sectionInset.left + flowLayout.sectionInset.right
        return CGSize(width: collectionView.frame.size.width - spacing, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        foodDelegate?.didSelect(food: items[indexPath.item])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.foodDelegate?.didFoodListScrolled()
    }
}
