//
//  Component.Skin.Switch.Simple.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 16/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit

extension Component.Skin.Switch {
    
    public class Simple {
        
        //MARK: - Options -
        
        public struct Options {
            
            public static let `default` = Options()
            
            public var handleColor: UIColor
            public var stateColor: StateColorPair
            public var shadow: ShadowOptions
            public init(handleColor: UIColor = .white,
                        stateColor: StateColorPair = (UIColor(hex: 0xDDDDDD), UIColor(hex: 0x6EDC5F)),
                        shadow: ShadowOptions = (offset: CGSize(width: 0, height: 3), blur: 5, color: UIColor.black.withAlphaComponent(0.5))) {
                self.handleColor = handleColor
                self.stateColor = stateColor
                self.shadow = shadow
            }
        }
        
        //MARK: - Class Init -
        
        private(set) public var id: String = UUID().uuidString
        private var handleRadius: CGFloat = 0
        private var containerRect: CGRect = .zero
        private var centers: StatePointPair = (off: CGPoint(x: 0, y: 0), on: CGPoint(x: 0, y: 0))
        public var options: Options
        
        required public init(options: Options) {
            self.options = options
        }
    }
}

//MARK: - ComponentSwitchSkinable

extension Component.Skin.Switch.Simple: ComponentSwitchSkinable {
    
    public func frameDidChange(rect: CGRect) {
        let edge = UIEdgeInsets(top: (options.shadow.offset.height < 0 ? -options.shadow.offset.height : 0) + options.shadow.blur,
                                left: (options.shadow.offset.width < 0 ? -options.shadow.offset.width : 0) + options.shadow.blur,
                                bottom: (options.shadow.offset.height > 0 ? options.shadow.offset.height : 0) + options.shadow.blur,
                                right: (options.shadow.offset.width > 0 ? options.shadow.offset.width : 0) + options.shadow.blur)
        
        handleRadius = (rect.height - edge.top - edge.bottom).half
        let containerMargin = handleRadius * 0.18
        containerRect = CGRect(x: containerMargin + edge.left,
                               y: containerMargin + edge.top,
                               width: rect.width - edge.left - edge.right - containerMargin.double,
                               height: rect.height - edge.top - edge.bottom - containerMargin.double)
        let yCenter = handleRadius + edge.top
        centers = (off: CGPoint(x: handleRadius + edge.left, y: yCenter), on: CGPoint(x: rect.width - handleRadius - edge.right, y: yCenter))
    }
    
    public func preferedSize() -> CGSize {
        return CGSize(width: 70, height: 44)
    }
    
    public func handleCenters() -> StatePointPair {
        return centers
    }
}

//MARK: - Drawing -

extension Component.Skin.Switch.Simple {
    
    public func draw(rect: CGRect, handlePosition: CGPoint, progressRatio: CGPoint) {
        let fillColor = options.stateColor.off.interpolateColorTo(options.stateColor.on, fraction: progressRatio.x)
        fillColor.setFill()
        UIBezierPath(roundedRect: containerRect, cornerRadius: containerRect.height.half).fill()
        
        Drawing.shadow(for: UIBezierPath(circleCenter: handlePosition, radius: handleRadius), shadow: options.shadow, colorFill: options.handleColor)
    }
}

