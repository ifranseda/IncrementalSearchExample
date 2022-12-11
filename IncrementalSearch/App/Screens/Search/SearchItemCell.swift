//
//  SearchItemCell.swift
//  IncrementalSearch
//
//  Created by Isnan Franseda on 12/11/22.
//

import Foundation
import UIKit

class SearchItemCell: UICollectionViewCell {
    
    let stackView: UIStackView = {
        let stackview = UIStackView()
        stackview.axis = .vertical
        stackview.spacing = 8
        stackview.layoutMargins = .init(top: 8, left: 8, bottom: 8, right: 8)
        return stackview
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .primaryText
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 1
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .primaryText
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.numberOfLines = 1
        return label
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addComponents()
        setLayoutConstraints()
    }
    
    private func addComponents() {
        contentView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
    }
    
    private func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
    }
    
    func configure(using item: Repository) {
        titleLabel.text = item.fullName
        descriptionLabel.text = item.htmlUrl
    }
}

extension UIColor {
    static var primaryText: UIColor {
        UIColor { (trait) -> UIColor in
            trait.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
        }
    }
}
