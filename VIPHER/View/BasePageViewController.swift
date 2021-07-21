//
//  BasePageViewController.swift
//  VIPHER
//
//  Created by Rajasekar on 20/07/21.
//

import UIKit
import HMSegmentedControl

// MARK: - ParentPageControlProtocol
protocol ParentPageControlProtocol : AnyObject {
    func assignCurrentChildScrollView(_ scrollView : UIScrollView)
    func didChildScrollViewScrolled(_ scrollView : UIScrollView)
}

// MARK: - ChildPageChange
enum ChildPageChange : Int {
    case willSelect
    case didSelect
    case didDeSelect
}

// MARK: - ChildPAgeControlProtocol
protocol ChildPageControlProtocol : AnyObject {
    func didSelectionChange(_ change : ChildPageChange)
}

// MARK: - BasePageViewController
class BasePageViewController<P : Presenterable> : BaseViewController<P>, UIPageViewControllerDataSource,UIPageViewControllerDelegate {
    
    // MARK: - Views
    internal var containerView : UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    internal var segmentedControl : SegmentControl = {
        let segmentedControl = SegmentControl()
        segmentedControl.backgroundColor = .defaultBackground
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    // MARK: - Constraints
    private weak var segmentControlHeightConstraint : NSLayoutConstraint?
    private weak var segmentControlWidthConstraint : NSLayoutConstraint?
   
    
    // MARK: - Properties
    internal var segmentControlDefaultHeight : CGFloat { return  80 }
    internal var isSegmentControlSizeToFit : Bool { return false }
    internal var segmentSelectedTintColor : UIColor { return UIColor.defaultTextColor }
    internal var segmentUnSelectedTintColor : UIColor { return UIColor.defaultTextColor.withAlphaComponent(0.5) }
    
    internal private(set) var controllers : [UIViewController] = [] {
        didSet {
            let segmentControlHeight = segmentControlHeightConstraint?.constant ?? 0
            if controllers.count <= 1 {
                if segmentControlHeight != 0 {
                    self.segmentedControl.alpha = 0
                    segmentControlHeightConstraint?.constant = 0
                    
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                }
            } else {
                if segmentControlHeight == 0 {
                    self.segmentedControl.alpha = 1
                    segmentControlHeightConstraint?.constant = segmentControlDefaultHeight
                    
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                }
            }
            
            setSegmentControlWidth()
        }
    }
    
    internal weak var pageViewController : UIPageViewController?
    
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        setSegmentControlWidth()
    }
    
    // MARK: - Child Control
    internal func setChildControllers(_ controllers : [UIViewController]) {
        guard let firstvc = controllers.first else {
            return
        }
        
        self.pageViewController?.setViewControllers([firstvc], direction: UIPageViewController.NavigationDirection.forward, animated: false)
        self.controllers = controllers
    }
    
    // MARK: - Segment control
    internal func setUpSegmentControl(titles: [String], images: [UIImage]?){
        segmentedControl.selectionStyle = .fullWidthStripe
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectionIndicatorLocation = .none
        segmentedControl.isVerticalDividerEnabled = true
        segmentedControl.verticalDividerColor = UIColor.clear
        segmentedControl.verticalDividerWidth = 1.0
        segmentedControl.selectionIndicatorBoxOpacity = 1.0
        segmentedControl.selectionIndicatorColor = .clear
        segmentedControl.selectionIndicatorHeight = 2
        
        if let images = images {
            segmentedControl.type = .textImages
            segmentedControl.imagePosition = .aboveText
            self.segmentedControl.sectionImages = images
        } else {
            segmentedControl.type = .text
        }
       
        segmentedControl.textImageSpacing = 2
        segmentedControl.addTarget(self, action: #selector(didChangeSegment), for: .valueChanged)
        let titleFormatterBlock: HMTitleFormatterBlock = { [weak self] (control: AnyObject!, title: String!, index: UInt, selected: Bool) -> NSAttributedString in
            
            guard let `self` = self else {
                return NSAttributedString()
            }
            
            if selected {
                let attString = NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor: self.segmentSelectedTintColor,
                                                                               NSAttributedString.Key.font : UIFont.systemFont(ofSize: 28, weight: .bold)
                    ])
                return attString
            } else {
                let attString = NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor: self.segmentUnSelectedTintColor,NSAttributedString.Key.font : UIFont.systemFont(ofSize: 28, weight: .bold)
                    ])
                return attString
            }
            
        }
        segmentedControl.titleFormatter = titleFormatterBlock
        self.segmentedControl.sectionTitles = titles
       
        self.segmentedControl.setSelectedSegmentIndex(0, animated: true)
    }
    
    internal func getSegmentControlTopConstraint() -> NSLayoutConstraint {
        return segmentedControl.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
    }
    
    @objc
    dynamic private func didChangeSegment() {
        let index = Int(segmentedControl.selectedSegmentIndex)
        setCurrentSelectionIndex(index)
    }
    
    func setCurrentSelectionIndex(_ index : Int) {
        if Int(segmentedControl.selectedSegmentIndex) != index {
            self.segmentedControl.setSelectedSegmentIndex(UInt(index), animated: true)
        }
        
        let oldIndex = controllers.firstIndex(of: self.pageViewController!.viewControllers!.first!) ?? 0
        if let currentVC = self.pageViewController?.viewControllers?.first , let currentIndex = controllers.firstIndex(of: currentVC),currentIndex != index {
            let newVC = controllers[index]
            
            (newVC as? ChildPageControlProtocol)?.didSelectionChange(.willSelect)
            
            self.pageViewController?.setViewControllers([newVC], direction: currentIndex < segmentedControl.selectedSegmentIndex ? UIPageViewController.NavigationDirection.forward : UIPageViewController.NavigationDirection.reverse, animated: true) { [weak self] (completed) in
               
                (self?.controllers[oldIndex] as? ChildPageControlProtocol)?.didSelectionChange(.didDeSelect)
                (newVC as? ChildPageControlProtocol)?.didSelectionChange(.didSelect)
            }
        }
    }

    // MARK: - UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = controllers.firstIndex(of: viewController),index > 0 {
            return controllers[index - 1]
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = controllers.firstIndex(of: viewController),index + 1 < controllers.count {
            return controllers[index + 1]
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        if let currentVC = pendingViewControllers.first {
            (currentVC as? ChildPageControlProtocol)?.didSelectionChange(.willSelect)
        }
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentVC = pageViewController.viewControllers?.first, let currentIndex = controllers.firstIndex(of: currentVC),  completed == true {
            
            (self.controllers[Int(self.segmentedControl.selectedSegmentIndex)] as? ChildPageControlProtocol)?.didSelectionChange(.didDeSelect)
            
            self.segmentedControl.setSelectedSegmentIndex(UInt(currentIndex), animated: true)
            (currentVC as? ChildPageControlProtocol)?.didSelectionChange(.didSelect)
        }
    }
}

extension BasePageViewController {
    private func setUp() {
        self.view.addSubview(segmentedControl)
        self.view.addSubview(containerView)
        
        let pageViewController = UIPageViewController(transitionStyle: UIPageViewController.TransitionStyle.scroll, navigationOrientation: UIPageViewController.NavigationOrientation.horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        addChild(pageViewController)
        containerView.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        var constraints : [NSLayoutConstraint] = []
        constraints.append(contentsOf: [
            pageViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pageViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        pageViewController.didMove(toParent: self)
        self.pageViewController = pageViewController
       
        segmentedControl.alpha = 0
        let segmentControlHeightConstraint = segmentedControl.heightAnchor.constraint(equalToConstant: 0)
        segmentControlWidthConstraint = segmentedControl.widthAnchor.constraint(equalToConstant : 100)
        
        constraints.append(contentsOf: [
            segmentedControl.leadingAnchor.constraint(greaterThanOrEqualTo : self.view.safeAreaLayoutGuide.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(lessThanOrEqualTo : self.view.safeAreaLayoutGuide.trailingAnchor),
            segmentedControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            segmentControlHeightConstraint,
            segmentControlWidthConstraint!,
            getSegmentControlTopConstraint(),
            
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate(constraints)
        self.segmentControlHeightConstraint = segmentControlHeightConstraint
    }
    
    private func setSegmentControlWidth() {
        if let segmentControlWidthConstraint = segmentControlWidthConstraint {
            let segmentWidth : CGFloat
            let viewWidth = self.view.frame.size.width
            if isSegmentControlSizeToFit {
                if let scrollView =  self.segmentedControl.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
                    segmentWidth = min(scrollView.contentSize.width,viewWidth)
                } else {
                    segmentWidth = viewWidth
                }
            } else {
                segmentWidth = viewWidth
            }
            
            if segmentControlWidthConstraint.constant != segmentWidth {
                segmentControlWidthConstraint.constant = segmentWidth
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }
}






// MARK: - SegmentControl
class SegmentControl : HMSegmentedControl {
    
    ///Return true if selection indicator layer is round corner esle false
    var isSelectionIndicatorRoundCorner : Bool = false
    
    ///Maximum width of the selection indicator
    ///0 meas automatic calcualtion
    var maxIndicatorWidth : CGFloat = 22
    
    override func draw(_ rect: CGRect) {
        if maxIndicatorWidth > 0 {
            let fullWidth = rect.size.width
            let itemWidth = fullWidth / CGFloat(self.sectionTitles?.count ?? 1)
            let maxStripeWidth = min(maxIndicatorWidth,itemWidth)
            
            let inset = (itemWidth - maxStripeWidth) / 2
            
            var indicatorInset = self.selectionIndicatorEdgeInsets
            indicatorInset.left = inset
            indicatorInset.right = inset
            self.selectionIndicatorEdgeInsets = indicatorInset
        }
        
        super.draw(rect)
        
        reloadCornerRadiusForIndicator(rect)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        reloadCornerRadiusForIndicator(self.bounds)
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        reloadCornerRadiusForIndicator(self.bounds)
    }
    
    private func reloadCornerRadiusForIndicator(_ rect : CGRect) {
        if isSelectionIndicatorRoundCorner,
           let view = subviews.first(where: { $0 is UIScrollView }) {
            
            let fullWidth = rect.size.width
            let itemWidth = fullWidth / CGFloat(self.sectionTitles?.count ?? 1)
            let maxStripeWidth = min(maxIndicatorWidth,itemWidth)
            
            let possibleStripYValue = rect.size.height -
                self.selectionIndicatorHeight + selectionIndicatorEdgeInsets.bottom
            
            ///get the layer of the indicator and update the corner radius
            if let layer = view.layer.sublayers?.first(where: { $0.frame.origin.y == possibleStripYValue && $0.frame.width == maxStripeWidth }) {
                layer.masksToBounds = true
                layer.cornerRadius = self.selectionIndicatorHeight / 2
            }
        }
    }
    
}
