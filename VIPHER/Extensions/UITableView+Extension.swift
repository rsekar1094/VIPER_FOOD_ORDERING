//
//  UITableView+Extension.swift
//  VIPHER
//
//  Created by Rajasekar on 20/07/21.
//

import UIKit

extension UITableViewCell {
    static var reuseIdentifier: String {
        return NSStringFromClass(self)
    }
}

extension UITableView {
    public func register<T: UITableViewCell>(_ cellClass: T.Type) {
        register(cellClass, forCellReuseIdentifier: cellClass.reuseIdentifier)
    }
    
    public func dequeue<T: UITableViewCell>(_ cellClass: T.Type) -> T {
        return dequeueReusableCell(withIdentifier: cellClass.reuseIdentifier) as! T
    }

    public func dequeue<T: UITableViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(
            withIdentifier: cellClass.reuseIdentifier, for: indexPath) as? T else {
                fatalError(
                    "Error: cell with id: \(cellClass.reuseIdentifier) for indexPath: \(indexPath) is not \(T.self)")
        }
        return cell
    }
}

extension UITableView {
    func indexPath(for view: UIView) -> IndexPath? {
        let point = self.convert(CGPoint.init(x: view.bounds.midX,y: view.bounds.midY), from:view)
        return self.indexPathForRow(at: point)
    }
}
