//
//  HomeViewController.swift
//  VIPHER
//
//  Created by Rajasekar on 19/07/21.
//

import Foundation
import UIKit

// MARK: - HomeViewController
class HomeViewController : BasePageViewController<HomePresenter> {
    
    // MARK: - Views
    internal lazy var bannerView : BannerView = {
        let bannerView = BannerView()
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.bannerDelegate = self
        return bannerView
    }()
    
    internal lazy var cartButton : CartButton = {
        let button = CartButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didPressCartButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Constraints
    private weak var bannerViewHeightConstraint : NSLayoutConstraint?
    private weak var containerViewHeightConstraint : NSLayoutConstraint?
    
    // MARK: - Properties
    private let bannerBottomMargin : CGFloat = 30
    private weak var childScrollView : UIScrollView?
    
    internal var _statusBarStyle : UIStatusBarStyle = .lightContent {
        didSet {
            ///set the status bar style and color based on the precentage it is moving
            if oldValue != _statusBarStyle {
                setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    private var bannerState : BannerState = .visible {
        didSet {
            ///reconfigure header state only if not equal  to old state or if old state transition inorder to update the header opacity
            if oldValue != bannerState || oldValue == .transition(0) {
                configureBannerState()
            }
        }
    }
    
    ///Data source of the complete view
    private var homeData : HomeData? {
        didSet {
            configureUI()
        }
    }
    
    // MARK: - Life cycle methods
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return _statusBarStyle
    }
    
    override func loadView() {
        let scrollView = UIScrollView()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.backgroundColor = .defaultBackground
        self.view = scrollView
    }
    
    override func viewDidLoad() {
        self.view.addSubview(bannerView)
        super.viewDidLoad()
        self.view.addSubview(cartButton)
        
        setUp()
        
        presenter.homeDataResponse.subscribe(onNext: { response in
            switch response {
            case .success(let homeData):
                self.homeData = homeData
            case .failure(let error):
                self.showAlert(title: NSLocalizedString("Error!", comment: ""), message: error.localizedDescription)
            }
        }, onError: { error in
            self.showAlert(title: NSLocalizedString("Error!", comment: ""), message: error.localizedDescription)
        }).disposed(by: disposeBag)
        
        presenter.currentCartItems.subscribe(onNext: { [weak self] response in
            switch response {
            case .success(let items):
                self?.cartButton.totalItem = items.count
            case .failure(_):
                break
            }
        }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.bannerView.invalidateLayout()
        }, completion: { _ in
            self.bannerView.reloadData()
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        segmentedControl.layer.masksToBounds = true
        segmentedControl.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        segmentedControl.layer.cornerRadius = 30
        assignHeightForSubContainers()
    }
    
    override func getSegmentControlTopConstraint() -> NSLayoutConstraint {
        segmentedControl.topAnchor.constraint(equalTo: bannerView.bottomAnchor,constant: -bannerBottomMargin)
    }
    
    // MARK: - Action buttons
    @objc
    private func didPressCartButton() {
        presenter.inputs.didSelectCartTrigger.onNext(())
    }
    
    // MARK: - configureBannerState
    private func configureBannerState() {
        switch self.bannerState {
        case .visible:
            _statusBarStyle = .lightContent
            bannerView.alpha = 1
            
            ///Disabling the child scroll
            childScrollView?.isScrollEnabled = false
        case .transition(let progress):
            if progress > 0.75 {
                if bannerView.alpha == 1 {
                    UIView.animate(withDuration: 0.2, animations: { self.bannerView.alpha = 1 - progress })
                } else {
                    bannerView.alpha = 1 - progress
                }
                _statusBarStyle = traitCollection.userInterfaceStyle == .light ? .darkContent : .lightContent
            } else {
                bannerView.alpha = 1
                _statusBarStyle = .lightContent
            }
            childScrollView?.isScrollEnabled = false
        case .hidden:
            bannerView.alpha = 0
            _statusBarStyle = traitCollection.userInterfaceStyle == .light ? .darkContent : .lightContent
            childScrollView?.isScrollEnabled = true
        }
    }
}

// MARK: - BannerDelegate
extension HomeViewController : BannerDelegate {
    func didSelect(banner: Banner) {
        presenter.inputs.didSelectBannerTrigger.onNext(banner)
    }
}

// MARK: - UIScrollViewDelegate
extension HomeViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        ///If user scroll beyond the banner then set the state as hidden
        ///if complete banner is visible then set it to visible
        ///else set banner state to transition - with how many percentage it is hidden
        
        ///since we wanted to stop child controllers below safe area, banner can visible on the safe area
        let bannerEndOffset = bannerView.frame.maxY - self.view.safeAreaInsets.top
        
        ///child controllers are overlayed on top of banner with  ```bannerBottomMargin``` so adding that to consider as current offset
        let currentOffset = scrollView.contentOffset.y + bannerBottomMargin
        
        if currentOffset == bannerView.frame.origin.x {
            self.bannerState = .visible
        } else if currentOffset >= bannerEndOffset {
            self.bannerState = .hidden
        } else {
            self.bannerState = .transition(currentOffset/bannerEndOffset)
        }
    }
    
}
// MARK: - ParentPageControlProtocol
extension HomeViewController : ParentPageControlProtocol {

    func assignCurrentChildScrollView(_ scrollView : UIScrollView) {
        self.childScrollView = scrollView
        configureBannerState()
    }
    
    func didChildScrollViewScrolled(_ scrollView : UIScrollView) {
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        
        ///If banner state is hidden  and  user is dragging the child controllers  and child scroll view is not at top then disable the child scroll view
        ///inorder to activate the parent scroll
        if self.bannerState == .hidden && scrollView.isDragging &&
            !scrollView.isDecelerating && scrollView.contentOffset.y <= scrollView.contentInset.top &&
            translation.y > 0 {
            scrollView.isScrollEnabled = false
        }
    }
    
    func didChildScrollViewEndDragging(_ scrollView : UIScrollView,willDecelerate : Bool) {
        
    }
    
    func didChildScrollViewEndDecelerate(_ scrollView : UIScrollView) {
       
    }
}

// MARK: - Utils
extension HomeViewController {
    
    private func configureUI() {
        guard let data = homeData else {
            return
        }
        
        self.bannerView.banners = data.banners
        
        if !data.foodTypes.isEmpty {
            let controllers = data.foodTypes.map { FoodListRouterInput().view(entryEntity: FoodListEntity(foodType: $0,parentControl: self)) }
            setChildControllers(controllers)
            setUpSegmentControl(titles: data.foodTypes.map { $0.name }, images: nil)
        }
    }
    
    func setUp() {
        bannerViewHeightConstraint = bannerView.heightAnchor.constraint(equalToConstant: 300)
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: 300)
        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            bannerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            bannerView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            
            containerView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            
            bannerViewHeightConstraint!,
            containerViewHeightConstraint!,
            
            cartButton.widthAnchor.constraint(equalToConstant: 50),
            cartButton.heightAnchor.constraint(equalToConstant: 50),
            cartButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            cartButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -30)
        ])
    }
    
    private func assignHeightForSubContainers() {
        guard let bannerViewHeightConstraint = bannerViewHeightConstraint,
              let containerViewHeightConstraint = containerViewHeightConstraint else {
            return
        }
        
        ///Banner will cover 70 percentage of the scrreen
        let bannerHeight = self.view.frame.size.height * 0.7
        
        var needLayout : Bool = false
        
        if bannerViewHeightConstraint.constant != bannerHeight {
            bannerViewHeightConstraint.constant = bannerHeight
            needLayout = true
        }
        
        ///Child container need to cover entirey without the safe area top and segment control height
        let containerHeight = self.view.frame.size.height -
            self.view.safeAreaInsets.top - self.segmentedControl.frame.size.height
        if containerViewHeightConstraint.constant != containerHeight {
            containerViewHeightConstraint.constant = containerHeight
            needLayout = true
        }
        
        if needLayout {
            self.view.setNeedsLayout()
        }
    }
}


// MARK: - BannerState
extension HomeViewController {
    
    enum BannerState : Equatable {
        case visible
        case hidden
        case transition(CGFloat)
        
        var id : String {
            switch self {
            case .visible:
                return "visible"
            case .hidden:
                return "hidden"
            case .transition:
                return "transition"
            }
        }
        
        static func ==(lhs : BannerState,rhs : BannerState) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
}



class CartButton : UIButton {
    
    var totalItem : Int = 0 {
        didSet {
            badgeLayer.isHidden = totalItem <= 0
            textLayer.string = "\(totalItem)"
        }
    }
    
    private let badgeLayer : CAShapeLayer
    private let textLayer : CATextLayer
    
    override init(frame: CGRect) {
        badgeLayer = CAShapeLayer()
        textLayer = CATextLayer()
        super.init(frame: frame)
        
        self.layer.addSublayer(badgeLayer)
        badgeLayer.addSublayer(textLayer)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = self.frame.size.height / 2
        
        let badgeRect : CGRect = CGRect(x: frame.width - 15, y: -4, width: 20, height: 20)
        textLayer.frame = badgeRect
        badgeLayer.path = UIBezierPath(roundedRect: badgeRect, cornerRadius: 10).cgPath
    }
    
    
    private func setUp() {
        self.backgroundColor = .defaultBackground
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
        self.setImage(UIImage(systemName: "cart",withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)),
                      for: .normal)
        self.tintColor = .theme
        
        badgeLayer.fillColor = UIColor.red.cgColor
        badgeLayer.strokeColor = UIColor.red.cgColor
    
        textLayer.fontSize = 15
        textLayer.foregroundColor = UIColor.white.cgColor
        textLayer.alignmentMode = .center
    }
}
