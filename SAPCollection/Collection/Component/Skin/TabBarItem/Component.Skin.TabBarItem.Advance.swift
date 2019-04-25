//
//  Component.Skin.TabBarItem.Advance.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 01/04/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit

extension Component.Skin.TabBarItem {
    
    public class Advance {
        
        //MARK: - Options -
        
        public struct Options {
            
            public static let `default` = Options(button: Button(shadow: [.normal: (offset: CGSize(width: 0, height: 6), blur: 6, color: UIColor.black.withAlphaComponent(0.3)),
                                                                          .selected: (offset: CGSize(width: 0, height: 2), blur: 2, color: UIColor.black.withAlphaComponent(0.4))]))
            
            public struct Button {
                public var shadow: [Component.View.Button.State: ShadowOptions]
                
                public init(shadow: [Component.View.Button.State: ShadowOptions]) {
                    self.shadow = shadow
                }
            }

            public var button: Button
            public var cornerRadius: CGFloat
            
            public init(button: Button, cornerRadius: CGFloat = 6) {
                self.button = button
                self.cornerRadius = cornerRadius
            }
        }
        
        //MARK: - Class Init -
        
        private(set) public var id: String = UUID().uuidString
    
        public var options: Options
        public var backgroundColors: ButtonStateColors
        public var titleAttributes: ButtonStateTitles
        public var images: ButtonStateImages
        public var drawingRect: CGRect = .zero
        
        required public init(options: Options,
                             backgroundColors: ButtonStateColors = [.normal: (UIColor(hex: 0xEFEFEF), UIColor(hex: 0xBABABA)),
                                                                    .selected: (UIColor(hex: 0xDBDBDB), UIColor(hex: 0xABABAB))]) {
            self.options = options
            self.backgroundColors = backgroundColors
            self.titleAttributes = [:]
            self.images =  [.normal: (nil, nil),
                            .highlighted: (nil, nil),
                            .disabled: (nil, nil),
                            .selected: (nil, nil)]
        }
    }
}

//MARK: - ComponentTabBarItemSkinable

extension Component.Skin.TabBarItem.Advance: ComponentTabBarItemSkinable {
    
    public func frameDidChange(rect: CGRect) {
        drawingRect = rect.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0))
    }
    
    public func preferedSize() -> CGSize {
        return .zero
    }
}

extension Component.Skin.TabBarItem.Advance {
    
    public func draw(rect: CGRect, stateTransition: ButtonTransitionStates, stateProgress: CGFloat, position: Component.View.TabBarItem.Position) {
        guard let from = backgroundColors[stateTransition.from] ?? nil,
            let to = backgroundColors[stateTransition.to] ?? nil
            else { return }
        
        let topColor = from.top.interpolateColorTo(to.top, fraction: stateProgress)
        let bottomColor = from.bottom.interpolateColorTo(to.bottom, fraction: stateProgress)
        
        let buttonPath: UIBezierPath
        switch position {
        case .first:
            buttonPath = UIBezierPath(roundedRect: drawingRect, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: options.cornerRadius.cgsize)
        case .intern:
            buttonPath = UIBezierPath(rect: drawingRect)
        case .last:
            buttonPath = UIBezierPath(roundedRect: drawingRect, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: options.cornerRadius.cgsize)
        }
        
        //Draw button
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let buttonGradient = CGGradient(colorsSpace: colorSpace, colors: gradientCFColors(gradientColor: (topColor, bottomColor)), locations: [0.0, 1.0]) else { return }
        
        Drawing.shadow(for: buttonPath, shadow: (offset: CGSize(width: 0, height: 2), blur: 2, color: UIColor.black.withAlphaComponent(0.4)))
        
        if let fromShadow = options.button.shadow[stateTransition.from],
            let toShadow = options.button.shadow[stateTransition.to] {
            let shadow = interpolate(from: fromShadow, to: toShadow, fraction: stateProgress)
            
            Drawing.shadow(for: buttonPath, shadow: shadow)
        }
        
        //Draw border top lighting
        Drawing.bevelEffect(gradientFill: buttonGradient, path: buttonPath, lightAlpha: 1)
        
        let state = stateTransition.to
        var imageRect: CGRect = .zero
        if let image = images[state]?.image ?? images[.normal]?.image {
            imageRect.size = image.size
            imageRect.origin.y = (drawingRect.height - imageRect.height).half + drawingRect.origin.y
            imageRect.origin.x = (drawingRect.width - image.size.width).half + drawingRect.origin.x

            UIColor.white.withAlphaComponent(0.4).setFill()
            image.draw(in: imageRect.offsetBy(dx: 0, dy: 1))
            
            if let tintColor = images[state]?.tintColor ?? images[.normal]?.tintColor {
                tintColor.setFill()
            } else {
                UIColor.black.setFill()
            }
            image.draw(in: imageRect)
        }
        
        if state == .selected {
            let shadow: ShadowOptions = (offset: CGSize(width: 0, height: 0), blur: 6, color: UIColor.black.withAlphaComponent(0.3))
            switch position {
            case .first:
                let path = UIBezierPath(rect: drawingRect.offsetBy(dx: drawingRect.width, dy: 0))
                Drawing.shadow(for: path, shadow: shadow)
            case .intern:
                let pathLeft = UIBezierPath(rect: drawingRect.offsetBy(dx: -drawingRect.width, dy: 0))
                Drawing.shadow(for: pathLeft, shadow: shadow)
                let pathRight = UIBezierPath(rect: drawingRect.offsetBy(dx: drawingRect.width, dy: 0))
                Drawing.shadow(for: pathRight, shadow: shadow)
            case .last:
                let path = UIBezierPath(rect: drawingRect.offsetBy(dx: -drawingRect.width, dy: 0))
                Drawing.shadow(for: path, shadow: shadow)
            }
        } else {
            guard let leftGradient = CGGradient(colorsSpace: colorSpace,
                                                colors: gradientCFColors(gradientColor: (UIColor(hex: 0xffffff), UIColor(hex: 0xbbbbbb))),
                                                locations: [0.0, 1.0]) else { return }
            guard let rightGradient = CGGradient(colorsSpace: colorSpace,
                                                 colors: gradientCFColors(gradientColor: (UIColor(hex: 0xdddddd), UIColor(hex: 0xa8a8a8))),
                                                 locations: [0.0, 1.0]) else { return }
            switch position {
            case .first:
                let pathRight = UIBezierPath(rect: CGRect(x: drawingRect.size.width - 1, y: 1, width: 1, height: drawingRect.size.height - 3))
                Drawing.linear(gradient: rightGradient, start: pathRight.bounds.origin, end: CGPoint(x: pathRight.bounds.origin.x, y: pathRight.bounds.maxY), mask: pathRight)
            case .intern:
                let pathLeft = UIBezierPath(rect: CGRect(x: 0, y: 1, width: 1, height: drawingRect.size.height - 3))
                Drawing.linear(gradient: leftGradient, start: pathLeft.bounds.origin, end: CGPoint(x: pathLeft.bounds.origin.x, y: pathLeft.bounds.maxY), mask: pathLeft)
                let pathRight = UIBezierPath(rect: CGRect(x: drawingRect.size.width - 1, y: 1, width: 1, height: drawingRect.size.height - 3))
                Drawing.linear(gradient: rightGradient, start: pathRight.bounds.origin, end: CGPoint(x: pathRight.bounds.origin.x, y: pathRight.bounds.maxY), mask: pathRight)
            case .last:
                let pathLeft = UIBezierPath(rect: CGRect(x: 0, y: 1, width: 1, height: drawingRect.size.height - 3))
                Drawing.linear(gradient: leftGradient, start: pathLeft.bounds.origin, end: CGPoint(x: pathLeft.bounds.origin.x, y: pathLeft.bounds.maxY), mask: pathLeft)
            }
        }
    }
    
    public func draw(rect: CGRect, stateTransition: ButtonTransitionStates, stateProgress: CGFloat) {
        
    }
}
