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
    func didFoodListEndDragging(willDecelerate : Bool)
    func didFoodListEndDecelerate()
}

enum FoodHeaderItem: String,Hashable {
    case main
}

// MARK: - FoodListView
class FoodListView : UICollectionView {
    
    // MARK: - Properties
    weak var foodDelegate : FoodListDelegate?
    var items : [Food] = [] {
        didSet {
            self.reloadSnapshot()
        }
    }
    private var foodDataSource: UICollectionViewDiffableDataSource<FoodHeaderItem, Food>!
    
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
        
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func didPressAction(_ button : UIButton) {
        guard let indexPath = self.indexPath(for: button) else {
            return
        }
        
        self.foodDelegate?.addToCart(food: items[indexPath.item])
    }
    
    public func addedFoodInToCart(food : Food,totalItemInCart : Int) {
        guard let index = self.items.firstIndex(where: { $0.id == food.id }),
                  let cell = self.cellForItem(at: IndexPath(item: index, section: 0)) as? FoodRowView else {
            return
        }
        
        cell.addedInToCart(totalItemInCart: totalItemInCart)
    }
    
    private func setUp() {
        self.register(FoodRowView.self)
        self.delegate = self
        self.backgroundColor = .defaultBackground
        self.contentInset = UIEdgeInsets.zero
        
        // MARK: Initialize data source
        self.foodDataSource = UICollectionViewDiffableDataSource<FoodHeaderItem, Food>(collectionView: self) {
            [weak self] (collectionView, indexPath, fileViewType) -> UICollectionViewCell? in
            
            guard let `self` = self else {
                return nil
            }
            
            let cell = collectionView.dequeue(FoodRowView.self, for: indexPath)
            cell.food = self.items[indexPath.item]
            cell.actionButton.addTarget(self, action: #selector(FoodListView.didPressAction(_:)), for: .touchUpInside)
            return cell
        }
    }
    
    private func reloadSnapshot() {
        DispatchQueue.main.async {
            var dataSourceSnapshot = NSDiffableDataSourceSnapshot<FoodHeaderItem, Food>()
            dataSourceSnapshot.appendSections([.main])
            dataSourceSnapshot.appendItems(self.items)
            self.foodDataSource.apply(dataSourceSnapshot,animatingDifferences: true)
            
            if self.items.isEmpty {
                let infoLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 500))
                infoLabel.text = NSLocalizedString("No Food!", comment: "")
                infoLabel.textColor = .defaultTextColor
                infoLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
                infoLabel.numberOfLines = 0
                infoLabel.textAlignment = .center
                self.backgroundView = infoLabel
            } else {
                self.backgroundView = nil
            }
        }
    }
}

// MARK: - DataSource + Delegate
extension FoodListView : UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = FoodRowView.getPreferHeight(for: items[indexPath.item], width: collectionView.frame.size.width)
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let spacing = flowLayout.sectionInset.left + flowLayout.sectionInset.right
        let numberColoumns : CGFloat
        if self.traitCollection.horizontalSizeClass == .regular {
            numberColoumns = 2
        } else {
            numberColoumns = 1
        }
        return CGSize(width: (collectionView.frame.size.width / numberColoumns) - spacing, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        foodDelegate?.didSelect(food: items[indexPath.item])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.foodDelegate?.didFoodListScrolled()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.foodDelegate?.didFoodListEndDecelerate()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.foodDelegate?.didFoodListEndDragging(willDecelerate: decelerate)
    }
}
