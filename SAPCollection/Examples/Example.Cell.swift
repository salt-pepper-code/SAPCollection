//
//  Example.Cell.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 21/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit
import Cartography
import SAPCollection

extension Example {

    class Cell: UITableViewCell {

        private let titleLabel = UILabel()
        private let stackView = UIStackView()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setup()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            titleLabel.text = ""
            let arrangedSubviews = stackView.arrangedSubviews
            arrangedSubviews.forEach {
                stackView.removeArrangedSubview($0)
            }
        }
        
        func set(contentSubview: UIView & Nameable) {
            let title = titleLabel.text ?? ""
            titleLabel.text = title + (title.isEmpty ? "" : " + ") + contentSubview.name.capitalized
            stackView.addArrangedSubview(contentSubview)
        }
    }
}

extension Example.Cell: Subviewable {
    
    func setupSubviews() {
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
    }
    
    func setupStyles() {
        titleLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
    }
    
    func setupHierarchy() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(stackView)
    }
    
    func setupAutoLayout() {
        constrain(titleLabel, stackView, contentView) { title, stack, view in
            title.top == view.top + 8
            title.leading == view.leading + 8
            title.trailing == view.trailing - 8
            
            stack.top == title.bottom + 8
            stack.leading == view.leading + 8
            stack.bottom == view.bottom - 16
        }
    }
}
