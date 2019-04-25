//
//  CGFloat+Extension.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 15/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import Foundation

protocol Subviewable {
    func setupSubviews()
    func setupStyles()
    func setupHierarchy()
    func setupAutoLayout()
}

extension Subviewable {
    func setup() {
        setupSubviews()
        setupStyles()
        setupHierarchy()
        setupAutoLayout()
    }
}
