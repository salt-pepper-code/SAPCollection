//
//  Component.Skin.Slider.Advance.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 18/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit

extension Component.Skin.Slider {
    
    public class Advance {
        
        //MARK: - Options -
        
        public struct Options {
            
            public static let `default` = Options(outterBevel: OutterBevel(gradientColor: (top: UIColor(hex: 0xececec), bottom: UIColor(hex: 0xf6f6f6)), innnerShadow: nil),
                                                  innerBevel: InnerBevel(rangeColor: (min: UIColor(hex: 0xd4d4d4), max: UIColor(hex: 0xd4d4d4)),
                                                                         innnerShadow: (offset: CGSize(width: 0, height: 3), blur: 6, color: UIColor.black.withAlphaComponent(0.2))),
                                                  handle: Handle(gradientColor: (top: UIColor(hex: 0xe6f7d4), bottom: UIColor(hex: 0x9fb889)),
                                                                 shadow: (offset: CGSize(width: 0, height: 2), blur: 3, color: UIColor.black.withAlphaComponent(0.5))),
                                                  handleBevel: HandleBevel(gradientColor: (top: UIColor(hex: 0xa8be93), bottom: UIColor(hex: 0xc2d6af))),
                                                  text: NumericText(font: UIFont(name: "HelveticaNeue-Medium", size: 11) ?? UIFont.systemFont(ofSize: 11),
                                                                    color: UIColor(hex: 0x888888),
                                                                    fractionDigits: (0, 0),
                                                                    unit: nil))
            
            public static let sharp = Options(outterBevel: OutterBevel(gradientColor: (UIColor(hex: 0xedf0f4), UIColor(hex: 0xedf0f4)),
                                                                       innnerShadow: (offset: CGSize(width: 0, height: 1), blur: 2, color: UIColor.black.withAlphaComponent(0.2))),
                                              innerBevel: InnerBevel(rangeColor: (min: UIColor(hex: 0xd1d6e1), max: UIColor(hex: 0xd1d6e1)),
                                                                     innnerShadow: (offset: CGSize(width: 0, height: 1), blur: 3, color: UIColor.black.withAlphaComponent(0.5))),
                                              handle: Handle(gradientColor: (top: UIColor(hex: 0xcff2b1), bottom: UIColor(hex: 0xaed190)),
                                                             shadow: (offset: CGSize(width: 0, height: 2), blur: 3, color: UIColor.black.withAlphaComponent(0.5))),
                                              handleBevel: HandleBevel(gradientColor: (top: UIColor(hex: 0x8fb072), bottom: UIColor(hex: 0xc9f0a6))),
                                              text: NumericText(font: UIFont(name: "HelveticaNeue-Medium", size: 11) ?? UIFont.systemFont(ofSize: 11),
                                                                color: UIColor(hex: 0x888888),
                                                                fractionDigits: (0, 0),
                                                                unit: nil))
            
            public struct InnerBevel {
                public var rangeColor: RangeColorPair
                public var innnerShadow: ShadowOptions?
                
                public init(rangeColor: RangeColorPair, innnerShadow: ShadowOptions?) {
                    self.rangeColor = rangeColor
                    self.innnerShadow = innnerShadow
                }
            }
            
            public var outterBevel: OutterBevel
            public var innerBevel: InnerBevel
            public var handle: Handle
            public var handleBevel: HandleBevel
            public var text: NumericText?
            
            public init(outterBevel: OutterBevel, innerBevel: InnerBevel, handle: Handle, handleBevel: HandleBevel, text: NumericText?) {
                self.outterBevel = outterBevel
                self.innerBevel = innerBevel
                self.handle = handle
                self.handleBevel = handleBevel
                self.text = text
            }
        }
        
        //MARK: - Class Init -
        
        private(set) public var id: String = UUID().uuidString
        private var attributes = [NSAttributedString.Key: Any]()
        
        private var handleHeight: CGFloat = 0
        private var containerOutterRingRect: CGRect = .zero
        private var containerOutterRingPath: UIBezierPath = UIBezierPath()
        private var containerInnerRect: CGRect = .zero
        private var containerInnerPath: UIBezierPath = UIBezierPath()
        
        private var handleRect: CGRect = .zero
        private var centers: RangePointPair = (min: CGPoint(x: 0, y: 0), max: CGPoint(x: 0, y: 0))
        private var handleMargin: CGFloat = 0
        
        private var outterGradient: CGGradient?
        private var handleGradient: CGGradient?
        private var handleHoleGradient: CGGradient?
        private var textContainerGradient: CGGradient?
        
        private var textHeight: CGFloat = 0
        private let textMargin: UIEdgeInsets
        private var textBottomSpacing: CGFloat = 0
        private let numberFormatter = NumberFormatter()
        
        public var options: Options {
            didSet {
                initialiase()
            }
        }
        
        required public init(options: Options) {
            self.options = options
            self.textMargin = options.text != nil ? UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8) : .zero
            self.textHeight = options.text != nil ? ceil("0".size(withAttributes: attributes).height) + textMargin.top + textMargin.bottom : 0
            self.initialiase()
        }
        
        private func initialiase() {
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            outterGradient = CGGradient(colorsSpace: colorSpace, colors: options.outterBevel.gradientCFColors(), locations: [0.0, 1.0])
            handleGradient = CGGradient(colorsSpace: colorSpace, colors: options.handle.gradientCFColors(), locations: [0.0, 1.0])
            handleHoleGradient = CGGradient(colorsSpace: colorSpace, colors: options.handleBevel.gradientCFColors(), locations: [0.0, 1.0])
            textContainerGradient = CGGradient(colorsSpace: colorSpace, colors: options.outterBevel.gradientCFColors(), locations: [1.0, 0.0])
            
            attributes = {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                return [
                    .paragraphStyle: paragraphStyle,
                    .font: self.options.text?.font ?? UIFont.systemFont(ofSize: 12),
                    .foregroundColor: self.options.text?.color ?? UIColor.black
                ]}()
        }
    }
}

//MARK: - ComponentSwitchSkinable

extension Component.Skin.Slider.Advance: ComponentSliderSkinable {
    
    public func handleCenters() -> RangePointPair {
        return centers
    }
    
    public func preferedSize() -> CGSize {
        return CGSize(width: 300, height: 36 + textHeight)
    }
    
    public func frameDidChange(rect: CGRect) {
        textBottomSpacing = round(rect.size.height / 10)
        containerOutterRingRect = rect.inset(by: UIEdgeInsets(top: textHeight + textBottomSpacing, left: 0, bottom: 0, right: 0))
        handleMargin = containerOutterRingRect.height / 6
        handleHeight = containerOutterRingRect.height / 4
        containerInnerRect = containerOutterRingRect.insetBy(dx: handleMargin+1, dy: handleMargin+1)
        handleRect = containerInnerRect.insetBy(dx: -1, dy: -1)
        centers = (min: CGPoint(x: containerOutterRingRect.minX + containerOutterRingRect.height.half, y: containerOutterRingRect.height.half),
                   max: CGPoint(x: containerOutterRingRect.maxX - containerOutterRingRect.height.half, y: containerOutterRingRect.height.half))
        
        containerOutterRingPath = UIBezierPath(roundedRect: containerOutterRingRect, cornerRadius: containerOutterRingRect.height.half)
        containerInnerPath = UIBezierPath(roundedRect: containerInnerRect, cornerRadius: containerInnerRect.height.half)
        containerOutterRingPath.append(containerInnerPath.reversing())
    }
}

//MARK: - DRAWING

extension Component.Skin.Slider.Advance {
    
    public func draw(rect: CGRect, handlePosition: CGPoint, progressRatio: CGPoint, value: CGFloat) {
        guard let outterGradient = outterGradient,
            let handleGradient = handleGradient,
            let handleHoleGradient = handleHoleGradient,
            let textContainerGradient = textContainerGradient else { return }
        
        //Draw container
        let totalWidth = containerInnerRect.insetBy(dx: -1, dy: -1).size.width
        handleRect.size.width = (totalWidth * progressRatio.x).clamped(to: handleRect.size.height...totalWidth)
        
        let fillColor = options.innerBevel.rangeColor.min.interpolateColorTo(options.innerBevel.rangeColor.max, fraction: progressRatio.x)
        Drawing.fill(path: containerInnerPath, mask: nil, colorFill: fillColor)
        
        if let shadow = options.innerBevel.innnerShadow {
            Drawing.innnerShadow(contextRect: rect, in: containerInnerPath, innnerShadow: shadow)
        }
        
        Drawing.linear(gradient: outterGradient,
                       start: containerOutterRingRect.origin,
                       end: CGPoint(x: containerOutterRingRect.origin.x, y: containerOutterRingRect.maxY),
                       mask: containerOutterRingPath)
        
        if let shadow = options.outterBevel.innnerShadow {
            let containerOutterRingPath = UIBezierPath(roundedRect: containerOutterRingRect, cornerRadius: containerOutterRingRect.height.half)
            Drawing.innnerShadow(contextRect: rect, in: containerOutterRingPath, innnerShadow: shadow)
        }
        
        //Draw Handler
        let handlePath = UIBezierPath(roundedRect: handleRect, cornerRadius: handleRect.height.half)
        
        if let shadow = options.handle.shadow {
            //Draw outter shadow
            Drawing.shadow(for: handlePath, shadow: shadow, colorFill: options.handle.gradientColor.top)
        }
        
        //Draw border top lighting, bottom shadow
        Drawing.bevelEffect(gradientFill: handleGradient, path: handlePath)
        
        //Draw hole
        let holeRadius = handleRect.height.half.half
        let holeCenter = CGPoint(x: handleRect.maxX - handleRect.height.half, y: containerOutterRingRect.height.half + containerOutterRingRect.origin.y)
        let holePath = UIBezierPath(circleCenter: holeCenter, radius: holeRadius)
        
        Drawing.embossEffect(gradientFill: handleHoleGradient, path: holePath, lightAlpha: 0.4)
        
        if let optionsText = options.text {
            //Draw Text
            let text: String
            if let unit = optionsText.unit {
                text = numberFormatter.string(value: value, fractionDigits: optionsText.fractionDigits) + " \(unit)"
            } else {
                text = numberFormatter.string(value: value, fractionDigits: optionsText.fractionDigits)
            }
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(x: holeCenter.x - textSize.width.half,
                                  y: textMargin.top,
                                  width: textSize.width,
                                  height: textSize.height)
            
            let textContainerRect = textRect.inset(by: UIEdgeInsets(top: -textMargin.top, left: -textMargin.left, bottom: -textMargin.bottom, right: -textMargin.right))
            let cornerRadius = textContainerRect.height / 4
            let textContainerPath = UIBezierPath(roundedRect: textContainerRect,
                                                 byRoundingCorners: [.allCorners],
                                                 cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
            
            let triangleSize = textContainerRect.size.height / 3
            let triangleContainerRect = CGRect(x: -triangleSize.half, y: -triangleSize.half, width: triangleSize, height: triangleSize)
            let triangleContainerPath = UIBezierPath(roundedRect: triangleContainerRect,
                                                     byRoundingCorners: [.allCorners],
                                                     cornerRadii: CGSize(width: cornerRadius / 4, height: cornerRadius / 4))
            triangleContainerPath.apply(CGAffineTransform(rotationAngle: 45.degreesToRadians))
            triangleContainerPath.apply(CGAffineTransform(translationX: textContainerRect.midX, y: textContainerRect.maxY))
            
            Drawing.linear(gradient: textContainerGradient,
                           start: textContainerRect.origin,
                           end: CGPoint(x: textContainerRect.origin.x, y: textContainerRect.maxY + triangleSize),
                           mask: textContainerPath + triangleContainerPath)
        
            NSAttributedString(string: text, attributes: attributes).draw(in: textRect)
        }
    }
}


