//
//  Component.Skin.Switch.Inner.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 16/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit

extension Component.Skin.Switch {
    
    public class Inner {

        //MARK: - Options -
        
        public struct Options {
            
            public static let `default` = Options()
            
            public var handleColor: UIColor
            public var stateColor: StateColorPair
            public init(handleColor: UIColor = .white,
                        stateColor: StateColorPair = (UIColor(hex: 0xDDDDDD), UIColor(hex: 0x6EDC5F))) {
                self.handleColor = handleColor
                self.stateColor = stateColor
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

extension Component.Skin.Switch.Inner: ComponentSwitchSkinable {
    
    public func frameDidChange(rect: CGRect) {
        let handleMargin: CGFloat = 2
        handleRadius = rect.height.half - handleMargin
        containerRect = rect
        let yCenter = handleRadius + handleMargin
        centers = (off: CGPoint(x: handleRadius + handleMargin, y: yCenter), on: CGPoint(x: rect.width - handleRadius - handleMargin, y: yCenter))
    }
    
    public func preferedSize() -> CGSize {
        return CGSize(width: 50, height: 30)
    }
    
    public func handleCenters() -> StatePointPair {
        return centers
    }
}

//MARK: - Drawing -

extension Component.Skin.Switch.Inner {
    
    public func draw(rect: CGRect, handlePosition: CGPoint, progressRatio: CGPoint) {
        let fillColor = options.stateColor.off.interpolateColorTo(options.stateColor.on, fraction: progressRatio.x)
        fillColor.setFill()
        UIBezierPath(roundedRect: containerRect, cornerRadius: containerRect.height.half).fill()
        
        options.handleColor.setFill()
        UIBezierPath(circleCenter: handlePosition, radius: handleRadius).fill()
    }
}
