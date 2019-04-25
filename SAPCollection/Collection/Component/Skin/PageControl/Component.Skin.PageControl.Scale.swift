//
//  Component.Skin.PageControl.Scale.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 16/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit

extension Component.Skin.PageControl {
    
    public class Scale {
        
        //MARK: - Options -
        
        public struct Options {
            
            public static let `default` = Options()
            
            public var radius: (min: CGFloat, max: CGFloat)
            public var distance: CGFloat
            public var dotColor: UIColor
            public var haloColors: [UIColor]?
            public var centers: [CGPoint] = []
            public init(radius: (min: CGFloat, max: CGFloat) = (min: 3, max: 6),
                        distance: CGFloat = 1.5,
                        dotColor: UIColor = .white,
                        haloColors: [UIColor]? = [UIColor(hex: 0xffffff, a: 0.5), UIColor(hex: 0xffffff, a: 0)]) {
                self.radius = radius
                self.distance = distance
                self.dotColor = dotColor
                self.haloColors = haloColors
            }
        }
        
        //MARK: - Class Init -
        
        private(set) public var id: String = UUID().uuidString
        public var options: Options
        
        required public init(options: Options) {
            self.options = options
        }
    }
}

//MARK: - ComponentPageControlSkinable

extension Component.Skin.PageControl.Scale: ComponentPageControlSkinable {
    
    public func preferedSize() -> CGSize {
        return CGSize(width: 120, height: 60)
    }
    
    public func frameDidChange(rect: CGRect) {
        
    }
}

//MARK: - Drawing -

extension Component.Skin.PageControl.Scale {
    
    public func draw(rect: CGRect, currentPage: CGFloat, numberOfPages: Int) {
        let space = rect.width / CGFloat(numberOfPages + 1)
        let centers = (0..<numberOfPages).map { CGPoint(x: (CGFloat($0 + 1) * space), y: rect.height.half)  }
        
        let radius = (0..<numberOfPages).map { int -> CGFloat in
            let index = CGFloat(int)
            let distance = abs(index - currentPage)
            if 0...options.distance ~= distance {
                return ((options.radius.max - options.radius.min) * ((options.distance - distance) / options.distance)) + options.radius.min
            }
            return options.radius.min
        }
        
        options.dotColor.setFill()
        centers.enumerated()
            .forEach { index, center in
                let radius = radius[index]
                if let haloColors = options.haloColors {
                    Drawing.radialGradient(colors: haloColors, locations: [0.0, 1.0], center: center, radius: radius * 1.5)
                }
                UIBezierPath(circleCenter: center, radius: radius).fill()
        }
    }
}

