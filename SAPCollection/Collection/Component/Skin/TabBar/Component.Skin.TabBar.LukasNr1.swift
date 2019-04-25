//
//  Component.Skin.TabBar.LukasNr1.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 29/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit

extension Component.Skin.TabBar {
    
    public class LukasNr1 {
        
        private(set) public var id: String = UUID().uuidString
        public var topMargin: CGFloat = 26
        public var backgroundColors: GradientVerticalColorPair
        
        required public init(backgroundColors: GradientVerticalColorPair = (UIColor(hex: 0xffffff), UIColor(hex: 0xffffff))) {
            self.backgroundColors = backgroundColors
        }
    }
}

//MARK: - ComponentTabBarSkinable

extension Component.Skin.TabBar.LukasNr1: ComponentTabBarSkinable {
    
    public func frameDidChange(rect: CGRect) {
        
    }
    
    public func preferedSize() -> CGSize {
        return CGSize(width: 0, height: 80)
    }
}

extension Component.Skin.TabBar.LukasNr1 {
    
    public func draw(rect: CGRect, indexCount: Int, fromIndex: Int, toIndex: Int, indexProgress: CGFloat) {
        guard let context = UIGraphicsGetCurrentContext()
            else { return }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let gradient = CGGradient(colorsSpace: colorSpace,
                                        colors: gradientCFColors(gradientColor: (backgroundColors.top, backgroundColors.bottom)),
                                        locations: [0.0, 1.0]) else { return }
    
        let fillPath = UIBezierPath(rect: rect.inset(by: UIEdgeInsets(top: topMargin, left: 0, bottom: 0, right: 0)))
        let fillBounds = fillPath.bounds
        
        let tabWidth = rect.width / CGFloat(indexCount)
        let start = CGPoint(x: tabWidth * indexProgress, y: topMargin)
        
        let shape = UIBezierPath()
        shape.move(to: CGPoint(x: 48.35, y: 34))
        shape.addCurve(to: CGPoint(x: 79.71, y: 13.08), controlPoint1: CGPoint(x: 62.42, y: 34), controlPoint2: CGPoint(x: 74.55, y: 25.28))
        shape.addCurve(to: CGPoint(x: 98, y: 0), controlPoint1: CGPoint(x: 81.43, y: 9.01), controlPoint2: CGPoint(x: 85.55, y: 0))
        shape.addCurve(to: CGPoint(x: 0, y: 0), controlPoint1: CGPoint(x: 98, y: 0), controlPoint2: CGPoint(x: 0, y: 0))
        shape.addCurve(to: CGPoint(x: 16.99, y: 13.08), controlPoint1: CGPoint(x: 12.36, y: 0), controlPoint2: CGPoint(x: 15.27, y: 9.01))
        shape.addCurve(to: CGPoint(x: 48.35, y: 34), controlPoint1: CGPoint(x: 22.15, y: 25.28), controlPoint2: CGPoint(x: 34.28, y: 34))
        shape.close()
        
        let shapeBounds = shape.bounds
        
        let translate = CGPoint(x: start.x + (tabWidth - shapeBounds.width).half, y: start.y)
        shape.apply(CGAffineTransform(translationX: translate.x, y: translate.y))
        
        let finalPah = fillPath - shape
        
        Drawing.linear(gradient: gradient, start: fillBounds.origin, end: CGPoint(x: fillBounds.origin.x, y: fillBounds.maxY), mask: finalPah)
    
        context.saveGState()
        UIColor.white.setFill()
        context.setBlendMode(.clear)
        shape.fill()
        context.restoreGState()
    }
}
