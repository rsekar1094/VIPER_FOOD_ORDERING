//
//  BaseViewController.swift
//  VIPHER
//
//  Created by Rajasekar on 19/07/21.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

// MARK: - BaseViewController
class BaseViewController<P : Presenterable> : UIViewController,Viewable {
    
    // MARK: - Properties
    private(set) var presenter: P!
    let disposeBag = DisposeBag()
    
    // MARK: - Views
    private var indicatorView : UIActivityIndicatorView = {
       let view = UIActivityIndicatorView()
        view.color = UIColor.theme
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initialziers
    init(presenter : P) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addIndicatorView()
        
        presenter.outputs.isLoading
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: indicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        presenter.inputs.viewDidLoadTrigger.onNext(())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view.bringSubviewToFront(indicatorView)
        presenter.inputs.viewDidAppearTrigger.onNext(())
    }
    
}

// MARK: - BaseViewController + Loader
extension BaseViewController {
    private func addIndicatorView() {
        self.view.addSubview(indicatorView)
        
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
    }
}
