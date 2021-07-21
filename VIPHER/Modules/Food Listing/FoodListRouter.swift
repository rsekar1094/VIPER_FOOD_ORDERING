//
//  FoodListRouter.swift
//  VIPHER
//
//  Created by Rajasekar on 20/07/21.
//

import Foundation
import UIKit

// MARK: - FoodListEntity
struct FoodListEntity {
    var foodType : FoodType
    var parentControl : ParentPageControlProtocol?
}


// MARK: - FoodListRouterInput
struct FoodListRouterInput {
    
    func view(entryEntity: FoodListEntity) -> FoodListViewController {
        let dependencies = FoodListPresenterDependencies(interactor : FoodListInteractor(foodType: entryEntity.foodType),
                                                         router : FoodListRouterOutput(nil))
        let view = FoodListViewController(presenter: FoodListPresenter(dependencies: dependencies))
        view.delegate = entryEntity.parentControl
        dependencies.router.view = view
        return view
    }

    func push(from: Viewable, entryEntity: FoodListEntity) {
        let view = self.view(entryEntity: entryEntity)
        from.push(view, animated: true)
    }

    func present(from: Viewable, entryEntity: FoodListEntity) {
        let nav = UINavigationController(rootViewController: view(entryEntity: entryEntity))
        from.present(nav, animated: true)
    }
}


// MARK: - FoodListRouterOutput
final class FoodListRouterOutput : Routerable {

    fileprivate(set) weak var view: Viewable!

    init(_ view: Viewable?) {
        self.view = view
    }
}
