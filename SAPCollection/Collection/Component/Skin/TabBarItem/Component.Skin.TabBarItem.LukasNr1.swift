//
//  Component.Skin.TabBarItem.LukasNr1.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 29/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit

extension Component.Skin.TabBarItem {
    
    public class LukasNr1 {
        
        private(set) public var id: String = UUID().uuidString
        private var containerRect: CGRect = .zero
        public var topMargin: CGFloat = 26
        
        public var backgroundColors: ButtonStateColors
        public var titleAttributes: ButtonStateTitles
        public var images: ButtonStateImages
        
        required public init() {
            self.backgroundColors = [.normal: (UIColor(hex: 0xffffff), UIColor(hex: 0xffffff))]
            self.titleAttributes = [:]
            self.images =  [:]
        }
    }
}

//MARK: - ComponentTabBarItemSkinable

extension Component.Skin.TabBarItem.LukasNr1: ComponentTabBarItemSkinable {

    public func frameDidChange(rect: CGRect) {
        containerRect = rect.inset(by: UIEdgeInsets(top: topMargin, left: 0, bottom: 0, right: 0))
    }
    
    public func preferedSize() -> CGSize {
        return .zero
    }
}

extension Component.Skin.TabBarItem.LukasNr1 {
    
    public func draw(rect: CGRect, stateTransition: ButtonTransitionStates, stateProgress: CGFloat, position: Component.View.TabBarItem.Position) {
        guard let from = backgroundColors[stateTransition.from] ?? nil,
            let to = backgroundColors[stateTransition.to] ?? nil
            else { return }
        
        let topColor = from.top.interpolateColorTo(to.top, fraction: stateProgress)
        let bottomColor = from.bottom.interpolateColorTo(to.bottom, fraction: stateProgress)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientCFColors(gradientColor: (topColor, bottomColor)), locations: [0.0, 1.0]) else { return }
        
        let stateFrom = stateTransition.from
        let stateTo = stateTransition.to
        
        var imageRect: CGRect = .zero
        if let image = images[stateTo]?.image {
            imageRect.size = image.size
            imageRect.origin.x = (containerRect.width - imageRect.width).half
        }
        
        let circleRadius: CGFloat = topMargin
        
        guard imageRect != .zero else { return }
        
        let bottom = ((containerRect.height - imageRect.height).half + topMargin)
        let top = topMargin - imageRect.height.half
        let diff = bottom - top
        
        switch (stateFrom, stateTo) {
        case (.normal, .selected), (.selected, .selected):
            imageRect.origin.y += (diff * (1 - stateProgress)) + top
        case (.selected, .normal):
            imageRect.origin.y += (diff * stateProgress) + top
        default:
            imageRect.origin.y += bottom
        }
        
        if stateTo == .selected || stateFrom == .selected {
            let circle = UIBezierPath(circleCenter: imageRect.center, radius: circleRadius)
            let circleBounds = circle.bounds
            Drawing.linear(gradient: gradient, start: circleBounds.origin, end: CGPoint(x: circleBounds.origin.x, y: circleBounds.maxY), mask: circle)
        }
        
        if let image = images[stateTo]?.image {
            if let tintFrom = images[stateFrom]?.tintColor, let tintTo = images[stateTo]?.tintColor {
                let tintColor = tintFrom.interpolateColorTo(tintTo, fraction: stateProgress)
                tintColor.setFill()
            } else {
                UIColor.black.setFill()
            }
            image.draw(in: imageRect)
        }
    }
    
    public func draw(rect: CGRect, stateTransition: ButtonTransitionStates, stateProgress: CGFloat) {

    }
}
