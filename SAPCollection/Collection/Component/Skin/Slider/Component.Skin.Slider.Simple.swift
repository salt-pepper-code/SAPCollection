//
//  Component.Skin.Slider.Simple.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 18/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit

extension Component.Skin.Slider {
    
    public class Simple {
        
        //MARK: - Options -
        
        public struct Options {
            
            public static let `default` = Options()
            
            public enum FillingMode {
                case leading
                case trailing
                case progressive
            }
            public var fillingMode: FillingMode
            public var direction: Component.Direction
            public var handleColor: UIColor
            public var handleSizeRatio: CGFloat
            public var rangeColor: RangeColorPair
            public var shadow: ShadowOptions
            public init(direction: Component.Direction = .horizontal,
                        handleColor: UIColor = .white,
                        handleSizeRatio: CGFloat = 0.5,
                        rangeColor: RangeColorPair = (min: UIColor(hex: 0xDDDDDD), max: UIColor(hex: 0x6EDC5F)),
                        shadow: ShadowOptions = (offset: CGSize(width: 0, height: 3), blur: 5, color: UIColor.black.withAlphaComponent(0.5)),
                        shadowBlur: CGFloat = 5,
                        fillingMode: FillingMode = .leading) {
                self.direction = direction
                self.handleColor = handleColor
                self.handleSizeRatio = handleSizeRatio
                self.rangeColor = rangeColor
                self.shadow = shadow
                self.fillingMode = fillingMode
            }
        }
        
        //MARK: - Class Init -
        
        private(set) public var id: String = UUID().uuidString
        private var handleRadius: CGFloat = 0
        private var containerRect: CGRect = .zero
        private var centers = (min: CGPoint(x: 0, y: 0), max: CGPoint(x: 0, y: 0))
        public var options: Options
        
        required public init(options: Options) {
            self.options = options
        }
    }
}

//MARK: - ComponentSwitchSkinable

extension Component.Skin.Slider.Simple: ComponentSliderSkinable {
    
    public func frameDidChange(rect: CGRect) {
        let edge = UIEdgeInsets(top: (options.shadow.offset.height < 0 ? -options.shadow.offset.height : 0) + options.shadow.blur,
                                left: (options.shadow.offset.width < 0 ? -options.shadow.offset.width : 0) + options.shadow.blur,
                                bottom: (options.shadow.offset.height > 0 ? options.shadow.offset.height : 0) + options.shadow.blur,
                                right: (options.shadow.offset.width > 0 ? options.shadow.offset.width : 0) + options.shadow.blur)
        switch options.direction {
        case .horizontal:
            handleRadius = (rect.height - edge.top - edge.bottom).half
            let containerMargin = handleRadius * options.handleSizeRatio
            containerRect = CGRect(x: containerMargin + edge.left,
                                   y: containerMargin + edge.top,
                                   width: rect.width - edge.left - edge.right - containerMargin.double,
                                   height: rect.height - edge.top - edge.bottom - containerMargin.double)
            let yCenter = handleRadius + edge.top
            centers = (min: CGPoint(x: handleRadius + edge.left, y: yCenter), max: CGPoint(x: rect.width - handleRadius - edge.right, y: yCenter))
        case .vertical:
            handleRadius = (rect.width - edge.left - edge.right).half
            let containerMargin = handleRadius * options.handleSizeRatio
            containerRect = CGRect(x: containerMargin + edge.left,
                                   y: containerMargin + edge.top,
                                   width: rect.width - edge.left - edge.right - containerMargin.double,
                                   height: rect.height - edge.top - edge.bottom - containerMargin.double)
            let xCenter = handleRadius + edge.left
            centers = (min: CGPoint(x: xCenter, y: handleRadius + edge.top), max: CGPoint(x: xCenter, y: rect.height - handleRadius - edge.bottom))
        }
    }
    
    public func preferedSize() -> CGSize {
        switch options.direction {
        case .horizontal:
            return CGSize(width: 200, height: 32)
        case .vertical:
            return CGSize(width: 32, height: 100)
        }
    }
    
    public func handleCenters() -> RangePointPair {
        return centers
    }
}

//MARK: - Drawing -

extension Component.Skin.Slider.Simple {
    
    public func draw(rect: CGRect, handlePosition: CGPoint, progressRatio: CGPoint, value: CGFloat) {
        let cornerRadius: CGFloat
        let splitRect: (first: CGRect, second: CGRect)
        switch options.direction {
        case .horizontal:
            splitRect = containerRect.horizontalSplit(ratio: progressRatio.x)
            cornerRadius = containerRect.height.half
        case .vertical:
            splitRect = containerRect.verticalSplit(ratio: progressRatio.y)
            cornerRadius = containerRect.width.half
        }
        
        switch options.fillingMode {
        case .leading:
            options.rangeColor.max.setFill()
            UIBezierPath(roundedRect: splitRect.first, cornerRadius: cornerRadius).fill()
            options.rangeColor.min.setFill()
            UIBezierPath(roundedRect: splitRect.second, cornerRadius: cornerRadius).fill()
        case .trailing:
            options.rangeColor.min.setFill()
            UIBezierPath(roundedRect: splitRect.first, cornerRadius: cornerRadius).fill()
            options.rangeColor.max.setFill()
            UIBezierPath(roundedRect: splitRect.second, cornerRadius: cornerRadius).fill()
        case .progressive:
            let fillColor = options.rangeColor.min.interpolateColorTo(options.rangeColor.max, fraction: progressRatio.x)
            fillColor.setFill()
            UIBezierPath(roundedRect: containerRect, cornerRadius: cornerRadius).fill()
        }
        
        Drawing.shadow(for: UIBezierPath(circleCenter: handlePosition, radius: handleRadius), shadow: options.shadow, colorFill: options.handleColor)
    }
}

