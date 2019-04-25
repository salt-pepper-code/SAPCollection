//
//  Component.Skin.TabBar.Advance.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 29/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit

extension Component.Skin.TabBar {
    
    public class Advance {
        
        //MARK: - Options -
        
        public struct Options {

            public var outterBevel: OutterBevel
            public var margins: UIEdgeInsets
            public var cornerRadius: CGFloat
            
            public init(outterBevel: OutterBevel = OutterBevel(gradientColor: (top: UIColor(hex: 0xE2E2E2), bottom: UIColor(hex: 0xFAFAFA)), innnerShadow: nil),
                        margins: UIEdgeInsets,
                        cornerRadius: CGFloat = 10) {
                self.outterBevel = outterBevel
                self.margins = margins
                self.cornerRadius = cornerRadius
            }
        }
        
        //MARK: - Class Init -
        
        private(set) public var id: String = UUID().uuidString
        private var containerOutterRingPath = UIBezierPath()
        private var outterGradient: CGGradient?
        public var options: Options
        
        required public init(options: Options) {
            self.options = options
        }
    }
}

//MARK: - ComponentTabBarSkinable

extension Component.Skin.TabBar.Advance: ComponentTabBarSkinable {
    
    public func frameDidChange(rect: CGRect) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        outterGradient = CGGradient(colorsSpace: colorSpace, colors: options.outterBevel.gradientCFColors(), locations: [0.0, 1.0])
        containerOutterRingPath = UIBezierPath(roundedRect: rect, cornerRadius: options.cornerRadius)
    }
    
    public func preferedSize() -> CGSize {
        return CGSize(width: 320, height: 60)
    }
}

extension Component.Skin.TabBar.Advance {
    
    public func draw(rect: CGRect, indexCount: Int, fromIndex: Int, toIndex: Int, indexProgress: CGFloat) {
        guard let outterGradient = outterGradient else { return }
        
        Drawing.linear(gradient: outterGradient,
                       start: rect.origin,
                       end: CGPoint(x: rect.origin.x, y: rect.maxY),
                       mask: containerOutterRingPath)
    }
}
