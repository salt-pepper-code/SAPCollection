//
//  Component.Skin.Button.Advance.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 24/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit


extension Component.Skin.Button {
    
    public class Advance {
        
        //MARK: - Options -
        
        public struct Options {
            
            public static let `default` = Options(outterBevel: OutterBevel(gradientColor: (top: UIColor(hex: 0xE2E2E2), bottom: UIColor(hex: 0xFAFAFA)),
                                                                           innnerShadow: (offset: CGSize(width: 0, height: 10), blur: 15, color: UIColor.black.withAlphaComponent(0.2))),
                                                  button: Button(shadow: [.normal: (offset: CGSize(width: 0, height: 12), blur: 6, color: UIColor.black.withAlphaComponent(0.3)),
                                                                          .highlighted: (offset: CGSize(width: 0, height: 2), blur: 2, color: UIColor.black.withAlphaComponent(0.4)),
                                                                          .disabled: (offset: CGSize(width: 0, height: 12), blur: 6, color: UIColor.black.withAlphaComponent(0.3)),
                                                                          .selected: (offset: CGSize(width: 0, height: 2), blur: 2, color: UIColor.black.withAlphaComponent(0.4))]),
                                                  margins: UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24))
            
            public struct Button {
                public var shadow: [Component.View.Button.State: ShadowOptions]
                
                public init(shadow: [Component.View.Button.State: ShadowOptions]) {
                    self.shadow = shadow
                }
            }
            
            public var outterBevel: OutterBevel
            public var button: Button
            public var margins: UIEdgeInsets
            
            public init(outterBevel: OutterBevel, button: Button, margins: UIEdgeInsets) {
                self.outterBevel = outterBevel
                self.margins = margins
                self.button = button
            }
        }
        
        //MARK: - Class Init -
        
        private(set) public var id: String = UUID().uuidString
        public static let defaultFont = UIFont(name: "HelveticaNeue-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        
        private var containerOutterRingRect: CGRect = .zero
        private var containerOutterRingPath: UIBezierPath = UIBezierPath()
        private var buttonRect: CGRect = .zero
        private var outterGradient: CGGradient?
        private let buttonMargin: CGFloat = 6
        private let cornerRadius: CGFloat = 6
        
        public var options: Options
        public var backgroundColors: ButtonStateColors
        public var titleAttributes: ButtonStateTitles {
            didSet {
                initialiase()
            }
        }
        public var images: ButtonStateImages
        public var imageSide: Side = .left
        
        private var attributes = [Component.View.Button.State: [NSAttributedString.Key: Any]]()
        private var lightAttributes = [Component.View.Button.State: [NSAttributedString.Key: Any]]()
        private var drawingText = [Component.View.Button.State: String?]()
        
        required public init(options: Options,
                             backgroundColors: ButtonStateColors = [.normal: (UIColor(hex: 0xefefef), UIColor(hex: 0xbababa)),
                                                                    .highlighted: (UIColor(hex: 0xdddddd), UIColor(hex: 0xbababa)),
                                                                    .disabled: (UIColor(hex: 0xdddddd), UIColor(hex: 0xbababa)),
                                                                    .selected: (UIColor(hex: 0xdddddd), UIColor(hex: 0xbababa))],
                             titleAttributes: ButtonStateTitles = [.normal: (nil, UIColor(hex: 0x696969), defaultFont),
                                                                   .highlighted: (nil, nil, nil),
                                                                   .disabled: (nil, UIColor(hex: 0x8d8d8d), nil),
                                                                   .selected: (nil, nil, nil)]) {
            self.options = options
            self.backgroundColors = backgroundColors
            self.titleAttributes = titleAttributes
            self.images =  [.normal: (nil, nil),
                            .highlighted: (nil, nil),
                            .disabled: (nil, nil),
                            .selected: (nil, nil)]
            self.initialiase()
        }
        
        private func initialiase() {
            Component.View.Button.State.all.forEach { state in
                attributes[state] = {
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = .center
                    return [
                        .paragraphStyle: paragraphStyle,
                        .font: self.titleAttributes[state]?.font ?? self.titleAttributes[.normal]?.font ?? Component.Skin.Button.Advance.defaultFont,
                        .foregroundColor: self.titleAttributes[state]?.color ?? self.titleAttributes[.normal]?.color ?? UIColor.black
                    ]}()
                lightAttributes[state] = {
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = .center
                    return [
                        .paragraphStyle: paragraphStyle,
                        .font: self.titleAttributes[state]?.font ?? self.titleAttributes[.normal]?.font ?? Component.Skin.Button.Advance.defaultFont,
                        .foregroundColor: UIColor.white.withAlphaComponent(0.5)
                    ]}()
                
                let text = titleAttributes[state]?.title ?? titleAttributes[.normal]?.title
                drawingText[state] = text
            }
        }
    }
}

//MARK: - ComponentButtonSkinable

extension Component.Skin.Button.Advance: ComponentButtonSkinable {
    
    public func frameDidChange(rect: CGRect) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        outterGradient = CGGradient(colorsSpace: colorSpace, colors: options.outterBevel.gradientCFColors(), locations: [0.0, 1.0])
        containerOutterRingRect = rect.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
        containerOutterRingPath = UIBezierPath(roundedRect: containerOutterRingRect, cornerRadius: 10)
        buttonRect = containerOutterRingRect.inset(by: UIEdgeInsets(top: buttonMargin, left: buttonMargin, bottom: buttonMargin, right: buttonMargin))
        initialiase()
    }
    
    private func sizeThatFits() -> CGSize {
        var size = CGSize(width: 44, height: 44)
        Component.View.Button.State.all.forEach { state in
            var textSize: CGSize = .zero
            if let drawingText = drawingText[state],
                let text = drawingText,
                let attributes = attributes[state] {
                
                let size = text.size(withAttributes: attributes)
                textSize = CGSize(width: ceil(size.width), height: ceil(size.height))
            }
            var imageSize: CGSize = .zero
            if let image = images[state]?.image{
                imageSize.width = image.size.width
            }
            if textSize.width > 0 && imageSize.width > 0 {
                size.width = max(size.width, textSize.width + imageSize.width + 8 + options.margins.horizontalMargins + buttonMargin.double)
            } else if textSize.width > 0 {
                size.width = max(size.width, textSize.width + options.margins.horizontalMargins + buttonMargin.double)
            } else if imageSize.width > 0 {
                size.width = max(size.width, imageSize.width + options.margins.horizontalMargins + buttonMargin.double)
            }
            size.height = max(44, textSize.height + buttonMargin.double + options.margins.verticalMargins + 10)
        }
        return size
    }
    
    public func preferedSize() -> CGSize {
        return sizeThatFits()
    }
}

//MARK: - Drawing -

extension Component.Skin.Button.Advance {
    
    public func draw(rect: CGRect, stateTransition: ButtonTransitionStates, stateProgress: CGFloat) {
        guard let outterGradient = outterGradient,
            let from = backgroundColors[stateTransition.from] ?? nil,
            let to = backgroundColors[stateTransition.to] ?? nil
            else { return }
        
        Drawing.linear(gradient: outterGradient,
                       start: containerOutterRingRect.origin,
                       end: CGPoint(x: containerOutterRingRect.origin.x, y: containerOutterRingRect.maxY),
                       mask: containerOutterRingPath)
        
        if let shadow = options.outterBevel.innnerShadow {
            Drawing.innnerShadow(contextRect: rect, in: containerOutterRingPath, innnerShadow: shadow)
        }
        
        let buttonPath = UIBezierPath(roundedRect: buttonRect, cornerRadius: cornerRadius)
        
        //Draw button
        let topColor = from.top.interpolateColorTo(to.top, fraction: stateProgress)
        let bottomColor = from.bottom.interpolateColorTo(to.bottom, fraction: stateProgress)
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
        var textRect: CGRect = .zero
        if let drawingText = drawingText[state],
            let text = drawingText,
            let attributes = attributes[state] {
            
            let textSize = text.size(withAttributes: attributes)
            textRect.size = CGSize(width: ceil(textSize.width), height: ceil(textSize.height))
            textRect.origin.y = (buttonRect.inset(by: options.margins).height - textRect.height).half + buttonRect.origin.y + options.margins.top
        }
        var imageRect: CGRect = .zero
        if let image = images[state]?.image{
            imageRect.size = image.size
            imageRect.origin.y = (buttonRect.height - options.margins.verticalMargins - imageRect.height).half + buttonRect.origin.y + options.margins.top
        }
        var size: CGSize = .zero
        if textRect.width > 0 && imageRect.width > 0 {
            size.width = textRect.width + imageRect.width + 8
            switch imageSide {
            case .left:
                imageRect.origin.x = (buttonRect.width - size.width).half + buttonRect.origin.x
                textRect.origin.x = imageRect.maxX + 8
            case .right:
                textRect.origin.x = (buttonRect.width - size.width).half + buttonRect.origin.x
                imageRect.origin.x = textRect.maxX + 8
            }
        } else if textRect.width > 0 {
            size.width = textRect.width
            textRect.origin.x = (buttonRect.width - size.width).half + buttonRect.origin.x
        } else if imageRect.width > 0 {
            size.width = imageRect.width
            imageRect.origin.x = (buttonRect.width - size.width).half + buttonRect.origin.x
        }
        
        if let drawingText = drawingText[state],
            let text = drawingText,
            let attributes = attributes[state] {
            
            NSAttributedString(string: text, attributes: attributes).draw(in: textRect)
        }
        
        if let image = images[state]?.image {
            if let tintColor = images[state]?.tintColor {
                tintColor.setFill()
            } else if let color = titleAttributes[state]?.color {
                color.setFill()
            } else {
                UIColor.black.setFill()
            }
            image.draw(in: imageRect)
        }
    }
}




