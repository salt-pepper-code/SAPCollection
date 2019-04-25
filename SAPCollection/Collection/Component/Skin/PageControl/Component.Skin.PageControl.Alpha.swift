//
//  Component.Skin.PageControl.Alpha.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 16/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit

extension Component.Skin.PageControl {
    
    public class Alpha {
        
        //MARK: - Options -
        
        public struct Options {
            
            public static let `default` = Options()
            
            public var radius: CGFloat
            public var alpha: (min: CGFloat, max: CGFloat)
            public var distance: CGFloat
            public var dotColor: UIColor
            public var haloColors: [UIColor]?
            public init(radius: CGFloat = 3,
                        alpha: (min: CGFloat, max: CGFloat) = (min: 0.5, max: 1),
                        distance: CGFloat = 1.5,
                        dotColor: UIColor = .white,
                        haloColors: [UIColor]? = [UIColor(hex: 0xffffff, a: 0.5), UIColor(hex: 0xffffff, a: 0)]) {
                self.alpha = alpha
                self.radius = radius
                self.distance = distance
                self.dotColor = dotColor
                self.haloColors = haloColors
            }
        }
        
        //MARK: - Class Init -
        
        public var options: Options
        private(set) public var id: String = UUID().uuidString
        
        required public init(options: Options) {
            self.options = options
        }
    }
}

//MARK: - ComponentPageControlSkinable

extension Component.Skin.PageControl.Alpha: ComponentPageControlSkinable {
    
    public func preferedSize() -> CGSize {
        return CGSize(width: 150, height: 60)
    }
    
    public func frameDidChange(rect: CGRect) {
        
    }
}

//MARK: - Drawing -

extension Component.Skin.PageControl.Alpha {
    
    public func draw(rect: CGRect, currentPage: CGFloat, numberOfPages: Int) {
        let space = rect.width / CGFloat(numberOfPages + 1)
        let centers = (0..<numberOfPages).map { CGPoint(x: (CGFloat($0 + 1) * space), y: rect.height.half)  }
        
        let alphas = (0..<numberOfPages).map { int -> CGFloat in
            let index = CGFloat(int)
            let distance = abs(index - currentPage)
            if 0...options.distance ~= distance {
                return ((options.alpha.max - options.alpha.min) * ((options.distance - distance) / options.distance)) + options.alpha.min
            }
            return options.alpha.min
        }
        
        centers.enumerated()
            .forEach { index, center in
                if let haloColors = options.haloColors {
                    Drawing.radialGradient(colors: haloColors, locations: [0.0, 1.0], center: center, radius: options.radius * 1.5)
                }
                options.dotColor.withAlphaComponent(alphas[index]).setFill()
                UIBezierPath(circleCenter: center, radius: options.radius).fill()
        }
    }
}

