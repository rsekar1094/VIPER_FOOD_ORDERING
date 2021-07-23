//
//  HomeRouterOutput.swift
//  VIPHER
//
//  Created by Rajasekar on 19/07/21.
//

import Foundation
import UIKit
import SafariServices

// MARK: - HomeEntity
struct HomeEntity {
    ///created empty now, in future if any parameters need to add then can add here
}

// MARK: - HomeRouterInput
struct HomeRouterInput {
    
    func view(entryEntity: HomeEntity) -> HomeViewController {
        let dependencies = HomePresenterDependencies(interactor : HomeInteractor(),router : HomeRouterOutput(nil))
        let view = HomeViewController(presenter: HomePresenter(dependencies: dependencies))
        dependencies.router.view = view
        return view
    }

    func push(from: Viewable, entryEntity: HomeEntity) {
        let view = self.view(entryEntity: entryEntity)
        from.push(view, animated: true)
    }

    func present(from: Viewable, entryEntity: HomeEntity) {
        let nav = UINavigationController(rootViewController: view(entryEntity: entryEntity))
        from.present(nav, animated: true)
    }
}

// MARK: - HomeRouterOutput
final class HomeRouterOutput : Routerable {

    // MARK: - Properties
    fileprivate(set) weak var view: Viewable!

    // MARK: - Initializers
    init(_ view: Viewable?) {
        self.view = view
    }
    
    // MARK: - Functions
    func openBanner(banner : Banner) {
        if let url = banner.actionUrl {
            let vc = SFSafariViewController(url: url)
            view.present(vc, animated: true)
        }
    }
    
    func openCart() {
        CartRouterInput().push(from: self.view, entryEntity: CartEntity())
    }
}
