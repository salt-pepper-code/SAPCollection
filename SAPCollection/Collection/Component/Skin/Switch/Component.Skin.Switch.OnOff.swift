//
//  Component.Skin.Switch.OnOff.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 16/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit

extension Component.Skin.Switch {
    
    public class OnOff {
        
        //MARK: - Options -
        
        public struct Options {
            
            public static let `default` = Options(outterBevel: OutterBevel(gradientColor: (top: UIColor(hex: 0xececec), bottom: UIColor(hex: 0xf6f6f6)), innnerShadow: nil),
                                                  innerBevel: InnerBevel(stateColor: (off: UIColor(hex: 0xd4d4d4), on: UIColor(hex: 0xd4d4d4)),
                                                                         innnerShadow: (offset: CGSize(width: 0, height: 3), blur: 6, color: UIColor.black.withAlphaComponent(0.2))),
                                                  handle: Handle(gradientColor: (top: UIColor(hex: 0xfce7ca), bottom: UIColor(hex: 0xcfa66e)),
                                                                 shadow: (offset: CGSize(width: 0, height: 2), blur: 3, color: UIColor.black.withAlphaComponent(0.5))),
                                                  handleBevel: HandleBevel(gradientColor: (top: UIColor(hex: 0xbfa073), bottom: UIColor(hex: 0xe5c59b))),
                                                  text: Text(font: UIFont(name: "HelveticaNeue-Medium", size: 11) ?? UIFont.systemFont(ofSize: 11),
                                                             width: 30,
                                                             color: UIColor(hex: 0x888888),
                                                             text: ("Off", "On")))
            
            public struct InnerBevel {
                public var stateColor: StateColorPair
                public var innnerShadow: ShadowOptions
                
                public init(stateColor: StateColorPair = (off: UIColor(hex: 0xd4d4d4), on: UIColor(hex: 0xd4d4d4)),
                            innnerShadow: ShadowOptions = (offset: CGSize(width: 0, height: 3), blur: 6, color: UIColor.black.withAlphaComponent(0.2))) {
                    self.stateColor = stateColor
                    self.innnerShadow = innnerShadow
                }
            }
            
            public struct Text {
                public var font: UIFont
                public var width: CGFloat
                public var color: UIColor
                public var text: (off: String, on: String)
                public init(font: UIFont = UIFont(name: "HelveticaNeue-Medium", size: 11) ?? UIFont.systemFont(ofSize: 11),
                            width: CGFloat = 30,
                            color: UIColor = UIColor(hex: 0x888888),
                            text: (off: String, on: String) = ("Off", "On")) {
                    self.font = font
                    self.width = width
                    self.color = color
                    self.text = text
                }
            }
            
            public var outterBevel: OutterBevel
            public var innerBevel: InnerBevel
            public var handle: Handle
            public var handleBevel: HandleBevel
            public var text: Text
            
            public init(outterBevel: OutterBevel, innerBevel: InnerBevel, handle: Handle, handleBevel: HandleBevel, text: Text) {
                self.outterBevel = outterBevel
                self.innerBevel = innerBevel
                self.handle = handle
                self.handleBevel = handleBevel
                self.text = text
            }
        }
        
        //MARK: - Class Init -
        
        private(set) public var id: String = UUID().uuidString
        private lazy var attributes: [NSAttributedString.Key: Any] = {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            return [
                .paragraphStyle: paragraphStyle,
                .font: self.options.text.font,
                .foregroundColor: self.options.text.color
            ]
        }()
        
        private var handleHeight: CGFloat = 0
        private var containerRect: CGRect = .zero
        private var containerInnerRect: CGRect = .zero
        private var handleRect: CGRect = .zero
        private var centers: StatePointPair = (off: CGPoint(x: 0, y: 0), on: CGPoint(x: 0, y: 0))
        private var handleMargin: CGFloat = 0
        
        public var options: Options
        
        required public init(options: Options) {
            self.options = options
        }
    }
}

//MARK: - ComponentSwitchSkinable

extension Component.Skin.Switch.OnOff: ComponentSwitchSkinable {
    
    public func frameDidChange(rect: CGRect) {
        handleMargin = rect.height / 6
        handleHeight = rect.height / 4
        containerRect = rect.insetBy(dx: options.text.width, dy: 0)
        containerInnerRect = containerRect.insetBy(dx: handleMargin+1, dy: handleMargin+1)
        handleRect = containerInnerRect.insetBy(dx: -1, dy: -1)
        handleRect.size.width = handleRect.height * 1.875
        centers = (off: CGPoint(x: options.text.width + handleMargin + handleRect.width.half, y: rect.height.half),
                   on: CGPoint(x: rect.width - options.text.width - handleMargin - handleRect.width.half, y: rect.height.half))
    }
    
    public func preferedSize() -> CGSize {
        return CGSize(width: 150, height: 36)
    }
    
    public func handleCenters() -> StatePointPair {
        return centers
    }
}

//MARK: - DRAWING

extension Component.Skin.Switch.OnOff {
    
    public func draw(rect: CGRect, handlePosition: CGPoint, progressRatio: CGPoint) {
        //Draw container
        let containerPath = UIBezierPath(roundedRect: containerRect, cornerRadius: containerRect.height.half)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let containerInnerRect = containerRect.insetBy(dx: handleMargin+1, dy: handleMargin+1)
        let containerInnerPath = UIBezierPath(roundedRect: containerInnerRect, cornerRadius: containerInnerRect.height.half)
        
        let fillColor = options.innerBevel.stateColor.off.interpolateColorTo(options.innerBevel.stateColor.on, fraction: progressRatio.x)
        Drawing.fill(path: containerInnerPath, mask: nil, colorFill: fillColor)
        
        Drawing.innnerShadow(contextRect: rect, in: containerInnerPath, innnerShadow: options.innerBevel.innnerShadow)
        
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: options.outterBevel.gradientCFColors(), locations: [0.0, 1.0]) else { return }
        
        Drawing.linear(gradient: gradient,
                       start: containerRect.origin,
                       end: CGPoint(x: containerRect.origin.x, y: containerRect.maxY),
                       mask: containerPath - containerInnerPath)
        
        //Draw Handler
        handleRect.origin.x = handlePosition.x - handleRect.width.half
        let handlePath = UIBezierPath(roundedRect: handleRect, cornerRadius: handleRect.height.half)
        
        if let shadow = options.handle.shadow {
            Drawing.shadow(for: handlePath, shadow: shadow, colorFill: options.handle.gradientColor.top)
        }
        
        guard let handleGradient = CGGradient(colorsSpace: colorSpace, colors: options.handle.gradientCFColors(), locations: [0.0, 1.0]) else { return }
        
        Drawing.bevelEffect(gradientFill: handleGradient, path: handlePath)
        
        //Draw hole
        guard let handleHoleGradient = CGGradient(colorsSpace: colorSpace, colors: options.handleBevel.gradientCFColors(), locations: [0.0, 1.0]) else { return }
        
        let diff = handleRect.width - handleRect.height
        let holeRadius = handleRect.height.half.half
        let circleCenter = CGPoint(x: handlePosition.x + (progressRatio.x * diff) - diff.half, y: rect.height.half)
        let holePath = UIBezierPath(circleCenter: circleCenter, radius: holeRadius)
        
        Drawing.embossEffect(gradientFill: handleHoleGradient, path: holePath, lightAlpha: 0.4)
        
        //Draw Text
        let offText = options.text.text.off
        let offTextSize = offText.size(withAttributes: attributes)
        let offTextRect = CGRect(x: (options.text.width - offTextSize.width).half,
                                 y: (rect.height - offTextSize.height).half,
                                 width: offTextSize.width,
                                 height: offTextSize.height)
        NSAttributedString(string: offText, attributes: attributes).draw(in: offTextRect)
        
        let onText = options.text.text.on
        let onTextSize = onText.size(withAttributes: attributes)
        let onTextRect = CGRect(x: rect.width - options.text.width + (options.text.width - onTextSize.width).half,
                                y: (rect.height - onTextSize.height).half,
                                width: onTextSize.width,
                                height: onTextSize.height)
        NSAttributedString(string: onText, attributes: attributes).draw(in: onTextRect)
    }
}


