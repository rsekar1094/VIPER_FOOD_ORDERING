//
//  FoodFilterView.swift
//  Vipher
//
//  Created by Rajasekar on 22/07/21.
//

import UIKit

// MARK: - FoodListDelegate
protocol FoodFilterDelegate : AnyObject {
    func doFilterFood(with filter : String?)
}

// MARK: - FoodFilterView
class FoodFilterView : UICollectionView {
    
    var filterTypes : [String] = [] {
        didSet {
            reloadData()
            if self.indexPathsForSelectedItems?.isEmpty ?? true {
                self.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .left)
            }
        }
    }
    weak var filterDelegate : FoodFilterDelegate?
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        super.init(frame: .zero, collectionViewLayout: layout)
        self.delegate = self
        self.dataSource = self
        self.showsHorizontalScrollIndicator = false
        self.backgroundColor = .clear
        self.allowsMultipleSelection = false
        self.allowsSelection = true
        
        self.register(FoodFilterRowView.self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getFilterString(indexPath : IndexPath) -> String {
        if indexPath.item == 0 {
            return NSLocalizedString("All", comment: "")
        } else{
            return filterTypes[indexPath.item - 1]
        }
    }
    
}
// MARK: - DataSource + Delegate
extension FoodFilterView : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterTypes.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(FoodFilterRowView.self, for: indexPath)
        cell.update(title : getFilterString(indexPath : indexPath).localizedCapitalized)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: FoodFilterRowView.getWidth(title: getFilterString(indexPath : indexPath).localizedCapitalized),
                      height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            filterDelegate?.doFilterFood(with: nil)
        } else {
            filterDelegate?.doFilterFood(with: getFilterString(indexPath: indexPath))
        }
    }

}


// MARK: - FoodFilterRowView
class FoodFilterRowView : UICollectionViewCell {
   
    public static func getWidth(title : String) -> CGFloat {
        return title.width(for: FoodFilterRowView.font) + 10 + (2 * FoodFilterRowView.padding)
    }
    
    override var isSelected: Bool {
        didSet {
            updateUI()
        }
    }
    
    private lazy var titleLabel : UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.defaultTextColor.withAlphaComponent(0.4)
        label.font = FoodFilterRowView.font
        label.textAlignment = .center
        return label
    }()
    
    private static let font : UIFont = UIFont.systemFont(ofSize: 12,weight: .medium)
    private static let padding : CGFloat = 15
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    private func setUp() {
        self.contentView.addSubview(titleLabel)
        updateUI()
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: FoodFilterRowView.padding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -FoodFilterRowView.padding),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.layer.borderColor = UIColor.theme.cgColor
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.cornerRadius = self.contentView.frame.size.height / 2
    }
    
    public func update(title : String) {
        self.titleLabel.text = title
        self.updateUI()
    }
    
    private func updateUI() {
        if isSelected {
            self.titleLabel.textColor = .white
            self.contentView.backgroundColor = UIColor.theme
        } else {
            self.titleLabel.textColor = .theme
            self.contentView.backgroundColor = UIColor.defaultBackground
        }
    }
}
