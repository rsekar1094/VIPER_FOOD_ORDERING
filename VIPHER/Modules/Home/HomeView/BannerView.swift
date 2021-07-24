//
//  BannerView.swift
//  VIPHER
//
//  Created by Rajasekar on 21/07/21.
//

import Foundation
import UIKit

// MARK: - BannerDelegate
protocol BannerDelegate : AnyObject {
    func didSelect(banner : Banner)
}

// MARK: - BannerView
class BannerView : UIView {
    
    // MARK: - Views
    private lazy var collectionView : UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.register(BannerRowView.self)
        view.contentInsetAdjustmentBehavior = .never
        return view
    }()
    
    private lazy var pageControl : UIPageControl = {
        let control = UIPageControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.currentPageIndicatorTintColor = .theme
        control.pageIndicatorTintColor = .white
        return control
    }()
    
    
    // MARK: - Properties
    var banners : [Banner] = [] {
        didSet {
            pageControl.numberOfPages = banners.count
            pageControl.currentPage = 0
            collectionView.reloadData()
        }
    }
    
    weak var bannerDelegate : BannerDelegate?
    
    
    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
      
        self.addSubview(collectionView)
        self.addSubview(pageControl)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            pageControl.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -50)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Life cycle methods
    override func layoutSubviews() {
        super.layoutSubviews()
        
        invalidateLayout()
    }
    
    // MARK: - PageControl + Updates
    private func updatePageControl() {
        let currentPage  = Int(collectionView.contentOffset.x / max(collectionView.frame.size.width,1))
        if currentPage != pageControl.currentPage {
            pageControl.currentPage = currentPage
        }
    }
    
    public func invalidateLayout() {
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    public func reloadData() {
        self.collectionView.reloadData()
    }
}

// MARK: - DataSource + Delegate
extension BannerView : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return banners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(BannerRowView.self, for: indexPath)
        cell.banner = banners[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: floor(collectionView.frame.width), height: floor(collectionView.frame.height))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        bannerDelegate?.didSelect(banner: banners[indexPath.item])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updatePageControl()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updatePageControl()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        updatePageControl()
    }
}





// MARK: - BannerRowView
class BannerRowView : UICollectionViewCell {
    
    // MARK: - View
    internal var imageView : UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.backgroundColor = UIColor.theme
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }()
    
    // MARK: - Properties
    var banner : Banner? {
        didSet {
            configure()
        }
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setUp()
    }
    
    // MARK: - Life cycle methods
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.image = nil
    }
    
    
    // MARK: - UI Configuration
    private func setUp() {
        self.contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
    
    private func configure() {
        guard let banner = self.banner else {
            self.imageView.image = nil
            return
        }
        
        imageView.setImage(url: banner.imageUrl)
    }
}



