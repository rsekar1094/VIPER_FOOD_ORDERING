//
//  CartRouter.swift
//  Vipher
//
//  Created by Rajasekar on 21/07/21.
//

import Foundation
import UIKit

// MARK: - CartEntity
struct CartEntity {
   
}


// MARK: - CartRouterInput
struct CartRouterInput {
    
    func view(entryEntity: CartEntity) -> CartViewController {
        let dependencies = CartPresenterDependencies(interactor : CartInteractor(),
                                                         router : CartRouterOutput(nil))
        let view = CartViewController(presenter: CartPresenter(dependencies: dependencies))
        dependencies.router.view = view
        return view
    }

    func push(from: Viewable, entryEntity: CartEntity) {
        let view = self.view(entryEntity: entryEntity)
        from.push(view, animated: true)
    }

    func present(from: Viewable, entryEntity: CartEntity) {
        let nav = UINavigationController(rootViewController: view(entryEntity: entryEntity))
        from.present(nav, animated: true)
    }
}


// MARK: - CartRouterOutput
final class CartRouterOutput : Routerable {

    fileprivate(set) weak var view: Viewable!

    init(_ view: Viewable?) {
        self.view = view
    }
    
    func assignTitle(_ title : String) {
        self.view.title = title
    }
}
