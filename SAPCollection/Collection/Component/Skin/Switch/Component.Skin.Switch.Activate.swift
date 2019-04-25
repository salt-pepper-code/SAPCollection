//
//  Component.Skin.Switch.Activate.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 16/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit

extension Component.Skin.Switch {
    
    public class Activate {
        
        //MARK: - Options -
        
        public struct Options {
            
            public static let `default` = Options(innerBevel: InnerBevel(stateColor: (off: UIColor(hex: 0xf4f5f6), on: UIColor(hex: 0xffd679)),
                                                                         innnerShadow: (offset: CGSize(width: 0, height: 0), blur: 6, color: UIColor.black.withAlphaComponent(0.2))),
                                                  handle: Handle(gradientColor: (top: UIColor(hex: 0xf4f5f6), bottom: UIColor(hex: 0xb3b7c2)),
                                                                 shadow: (offset: CGSize(width: 0, height: 6), blur: 12, color: UIColor.black.withAlphaComponent(0.5))),
                                                  handleBevel: HandleBevel(gradientColor: (top: UIColor(hex: 0xd2d2d2), bottom: UIColor(hex: 0xf4f5f6))))
            
            public struct InnerBevel {
                public var stateColor: StateColorPair
                public var innnerShadow: ShadowOptions
                
                public init(stateColor: StateColorPair, innnerShadow: ShadowOptions) {
                    self.stateColor = stateColor
                    self.innnerShadow = innnerShadow
                }
            }
            
            public var innerBevel: InnerBevel
            public var handle: Handle
            public var handleBevel: HandleBevel
            
            public init(innerBevel: InnerBevel, handle: Handle, handleBevel: HandleBevel) {
                self.innerBevel = innerBevel
                self.handle = handle
                self.handleBevel = handleBevel
            }
        }
        
        //MARK: - Class Init -
        
        private(set) public var id: String = UUID().uuidString
        private var handleRadius: CGFloat = 0
        private var containerRect: CGRect = .zero
        private var centers = (off: CGPoint(x: 0, y: 0), on: CGPoint(x: 0, y: 0))
        public var image: UIImage?
        public var options: Options
        
        required public init(image: UIImage?, options: Options) {
            self.image = image
            self.options = options
        }
    }
}

//MARK: - ComponentSwitchSkinable

extension Component.Skin.Switch.Activate: ComponentSwitchSkinable {
    
    public func frameDidChange(rect: CGRect) {
        let handleMargin = rect.height * 0.08
        let outterMargin: CGFloat = 8
        handleRadius = rect.height.half - handleMargin - outterMargin
        containerRect = rect.insetBy(dx: outterMargin, dy: outterMargin)
        let yCenter = handleRadius + handleMargin + outterMargin
        centers = (off: CGPoint(x: handleRadius + handleMargin + outterMargin, y: yCenter),
                   on: CGPoint(x: rect.width - handleRadius - handleMargin - outterMargin, y: yCenter))
    }
    
    public func preferedSize() -> CGSize {
        return CGSize(width: 280, height: 120)
    }
    
    public func handleCenters() -> StatePointPair {
        return centers
    }
}

//MARK: - DRAWING

extension Component.Skin.Switch.Activate {
    
    public func draw(rect: CGRect, handlePosition: CGPoint, progressRatio: CGPoint) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let handlePosition = CGPoint(x: centers.off.x + ((centers.on.x - centers.off.x) * progressRatio.x.half), y: handlePosition.y)
        
        //Draw container
        //Calculate shrinking width
        var containerRect = self.containerRect
        let substractedWidth = (containerRect.size.width - containerRect.size.height) * progressRatio.x.half
        containerRect.origin.x = containerRect.origin.x + substractedWidth
        containerRect.size.width -= substractedWidth.double
        
        //Fill container color
        let stateColor = options.innerBevel.stateColor.off.interpolateColorTo(options.innerBevel.stateColor.on, fraction: progressRatio.x)
        let innerPath = UIBezierPath(roundedRect: containerRect, cornerRadius: containerRect.height.half)
        
        Drawing.fill(path: innerPath, mask: nil, colorFill: stateColor)
        
        Drawing.innnerShadow(contextRect: rect, in: innerPath, innnerShadow: options.innerBevel.innnerShadow)
        
        //Draw handle
        var handlePath = UIBezierPath(circleCenter: handlePosition, radius: handleRadius)
        
        if let shadow = options.handle.shadow {
            //Outer shadow
            Drawing.shadow(for: handlePath, shadow: shadow, colorFill: options.handle.gradientColor.top)
        }
        
        //Gradient
        guard let handleGradient = CGGradient(colorsSpace: colorSpace, colors: options.handle.gradientCFColors(), locations: [0.2, 1.0]) else { return }
        Drawing.linear(gradient: handleGradient,
                       start: handlePosition.offset(dx: 0, dy: -handleRadius),
                       end: handlePosition.offset(dx: 0, dy: handleRadius),
                       mask: handlePath)
        
        //Draw border top lighting
        Drawing.bevelEffect(gradientFill: nil, path: handlePath)
        
        //Draw inner handle circle
        handlePath = UIBezierPath(circleCenter: handlePosition, radius: handleRadius.half)
        //Gradient
        Drawing.shapedLinearGradient(path: handlePath,
                                     colors: options.handleBevel.gradientUIColors(),
                                     locations: [0.0, 1.0],
                                     startPoint: handlePosition.offset(dx: 0, dy: -handleRadius.half),
                                     endPoint: handlePosition.offset(dx: 0, dy: handleRadius.half))
        
        //Draw icon
        if let image = image {
            context.saveGState()
            stateColor.setFill()
            let size = image.size
            let drawingWidth = handleRadius.half
            let drawingHeight = (drawingWidth * size.height) / size.width
            let rect = CGRect(x: handlePosition.x - drawingWidth.half, y: handlePosition.y - drawingHeight.half, width: drawingWidth, height: drawingHeight)
            context.setShadow(offset: CGSize(width: 0, height: 0), blur: 1, color: UIColor.black.withAlphaComponent(0.8).cgColor)
            image.withRenderingMode(.alwaysTemplate).draw(in: rect)
            context.restoreGState()
        }
    }
}
