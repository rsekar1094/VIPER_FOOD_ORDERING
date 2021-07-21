//
//  UICollectionView+Extension.swift
//  VIPHER
//
//  Created by Rajasekar on 20/07/21.
//

import UIKit

extension UICollectionViewCell {
    static var reuseIdentifier: String {
        return NSStringFromClass(self)
    }
}

extension UICollectionView {
    
    public func register<T: UICollectionViewCell>(_ cellClass: T.Type) {
        register(cellClass, forCellWithReuseIdentifier: cellClass.reuseIdentifier)
    }
    
    public func dequeue<T: UICollectionViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(
            withReuseIdentifier: cellClass.reuseIdentifier, for: indexPath) as? T else {
                fatalError(
                    "Error: cell with id: \(cellClass.reuseIdentifier) for indexPath: \(indexPath) is not \(T.self)")
        }
        return cell
    }
}

extension UICollectionView {
    func indexPath(for view: UIView) -> IndexPath? {
        let viewCenterRelativeToTableview = self.convert(CGPoint.init(x: view.bounds.midX,
                                                                      y: view.bounds.midY), from:view)
        return self.indexPathForItem(at: viewCenterRelativeToTableview)
    }
}
