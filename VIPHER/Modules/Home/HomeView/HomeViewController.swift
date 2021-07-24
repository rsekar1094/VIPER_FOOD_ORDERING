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
    private var collapsableData : [String : CollapsableData] = [:]
    
    ///Maximum banner height which can it holds - 70 percentage of it's view
    private var MAX_BANNER_HEIGHT : CGFloat { return self.view.frame.size.height * 0.7 }
    
    ///Minimum banner height can have - safe area top + Bottom margin
    private var MIN_BANNER_HEIGHT : CGFloat { return self.view.safeAreaInsets.top + bannerBottomMargin }
    
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
        scrollView.backgroundColor = .black
        self.view = scrollView
    }
    
    override func viewDidLoad() {
        self.view.addSubview(bannerView)
        super.viewDidLoad()
        self.view.addSubview(cartButton)
        
        
        setUp()
        
        ///Listen for the home data and when response comes  reload the UI
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
        
        
        ///Listen to the cart items change
        ///Update the unique items count in the cart based on this to the cart button
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
        
        assignHeightForSubContainers()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        assignHeightForSubContainers()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.bannerView.invalidateLayout()
        }, completion: { _ in
            self.bannerView.reloadData()
            self.assignHeightForSubContainers()
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        segmentedControl.layer.masksToBounds = true
        segmentedControl.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        segmentedControl.layer.cornerRadius = 30
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
            self.view.backgroundColor = .black
            
        case .transition(let progress):
            if progress > 0.75 {
                if bannerView.alpha == 1 {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.bannerView.alpha = 1 - progress
                        self.view.backgroundColor = .defaultBackground
                    })
                } else {
                    bannerView.alpha = 1 - progress
                    self.view.backgroundColor = .defaultBackground
                }
                _statusBarStyle = traitCollection.userInterfaceStyle == .light ? .darkContent : .lightContent
            } else {
                bannerView.alpha = 1
                _statusBarStyle = .lightContent
                self.view.backgroundColor = .black
            }
        case .hidden:
            bannerView.alpha = 0
            self.view.backgroundColor = .defaultBackground
            _statusBarStyle = traitCollection.userInterfaceStyle == .light ? .darkContent : .lightContent
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
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let data : CollapsableData
        if let collapsableData = collapsableData[scrollView.instanceId] {
            data = collapsableData
        } else {
            data = CollapsableData()
            collapsableData[scrollView.instanceId] = data
        }
        
        let touchPoint : CGPoint
        
        if scrollView == view {
            let point = scrollView.panGestureRecognizer.location(in: self.view.superview!)
            touchPoint = point//CGPoint(x: point.x, y: CGFloat(Int(point.y) % Int(self.view.frame.height)))
        } else {
            touchPoint = scrollView.panGestureRecognizer.location(in: self.view)
        }
       
        data.previousTouchPoint = touchPoint
        data.previousContentOffset = scrollView.contentOffset
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let bannerHeightConstraint = self.bannerViewHeightConstraint else {
            return
        }
        
        guard let collapsableData = self.collapsableData[scrollView.instanceId] else {
            return
        }
        
        let touchPoint : CGPoint
        if scrollView == view {
            ///if current view itself scroll view then find the location based on its parent view, inorder to avoid zero differnece
            let point = scrollView.panGestureRecognizer.location(in: self.view.superview!)
            touchPoint = point
        } else {
            touchPoint = scrollView.panGestureRecognizer.location(in: self.view)
        }
        
        let diff = touchPoint.y - collapsableData.previousTouchPoint.y
        
        guard diff != 0 else {
            if scrollView == self.view && scrollView.isDecelerating {
                ///if it is decelerating then set the appropriae state based on its content offset point
                
                let currentOffset = scrollView.contentOffset.y + bannerBottomMargin
                 
                if currentOffset == bannerView.frame.origin.x {
                     self.bannerState = .visible
                 } else if bannerHeightConstraint.constant == MIN_BANNER_HEIGHT {
                     self.bannerState = .hidden
                 } else {
                    let percentage = (scrollView.contentOffset.y) / (segmentedControl.frame.origin.y - self.view.safeAreaInsets.top)
                    let bannerHiddenPercentage = min(max(percentage,0),1)
                    self.bannerState = .transition(bannerHiddenPercentage)
                 }
                
                 assignHeightForSubContainers()
                return
            }
            return
        }
        
        var newBannerHeight : CGFloat = bannerHeightConstraint.constant
        newBannerHeight = bannerHeightConstraint.constant + diff
        
        if newBannerHeight > MAX_BANNER_HEIGHT {
            newBannerHeight = MAX_BANNER_HEIGHT
        } else if newBannerHeight < MIN_BANNER_HEIGHT {
            newBannerHeight = MIN_BANNER_HEIGHT
        }
        
        ///if new height and old height not equal then only assign
        ///resent offset of scroll to previous sicne user pan help to expand/collapse - scrollview need to stay where ever it was there
        if newBannerHeight != bannerHeightConstraint.constant {
            bannerView.invalidateLayout()
            bannerHeightConstraint.constant = newBannerHeight
            scrollView.contentOffset = collapsableData.previousContentOffset
        }
        
        collapsableData.previousContentOffset = scrollView.contentOffset
        
        ///if height is equal to MAX then expanded
        ///else if equal to MIN then collapsed
        ///else -- it is in between of collapsing state
        if bannerHeightConstraint.constant == MAX_BANNER_HEIGHT {
            self.bannerState = .visible
        } else if bannerHeightConstraint.constant == MIN_BANNER_HEIGHT {
            self.bannerState = .hidden
        } else {
            self.bannerState = .transition(1 - (bannerHeightConstraint.constant / MAX_BANNER_HEIGHT))
        }
        
        collapsableData.previousTouchPoint = touchPoint
    }
    
}
// MARK: - ParentPageControlProtocol
extension HomeViewController : ParentPageControlProtocol {
    
    func assignCurrentChildScrollView(_ scrollView : UIScrollView) {
        self.childScrollView = scrollView
        configureBannerState()
    }
    
    func willChildScrollViewBeginDragging(_ scrollView : UIScrollView) {
        scrollViewWillBeginDragging(scrollView)
    }
    
    func didChildScrollViewScrolled(_ scrollView : UIScrollView) {
        guard let collapsableData = self.collapsableData[scrollView.instanceId] else {
            return
        }
        
        let touchPoint = scrollView.panGestureRecognizer.location(in: self.view)
        
        let diff = touchPoint.y - collapsableData.previousTouchPoint.y
        
        let isScrollingDown : Bool
        //scroll down
        if diff < 0 {
            isScrollingDown = true
        } else if diff > 0 { //scroll up
            isScrollingDown = false
        } else {
            return
        }
        
        if !isScrollingDown && scrollView.contentOffset.y > scrollView.contentInset.top && self.bannerState == .hidden {
            ///if scrolling up and content offset is greater than it's inset/zero then
            ///do nothing to change on banner height
            ///just scroll inside the child area
            collapsableData.previousTouchPoint = touchPoint
            return
        }
        
        scrollViewDidScroll(scrollView)
    }
    
    func didChildScrollViewEndDragging(_ scrollView : UIScrollView,willDecelerate : Bool) {
        
    }
    
    func didChildScrollViewEndDecelerate(_ scrollView : UIScrollView) {
        
    }
    
    func didChildScrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                           targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
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
        
        
        let bannerHeight : CGFloat
        switch bannerState {
        case .visible:
            bannerHeight = MAX_BANNER_HEIGHT
        case .hidden:
            bannerHeight = MIN_BANNER_HEIGHT
        case .transition(let hidePercentage):
            let totalHeight =  MAX_BANNER_HEIGHT
            let height = totalHeight - (totalHeight * hidePercentage)
            bannerHeight = max(height,MIN_BANNER_HEIGHT)
        }
        
        var needLayout : Bool = false
        
        if bannerViewHeightConstraint.constant != bannerHeight {
            bannerView.invalidateLayout()
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


// MARK: - CollapsableData
class CollapsableData {
    
    ///Previous content Offset before they did scroll
    ///used to set it back to older if something change while expand/collapse
    public var previousContentOffset : CGPoint = .zero
    
    ///Previous touch point on their scrollview
    ///used to find the difference in panning location
    public var previousTouchPoint : CGPoint = .zero
}

