//
//  Component.Skin.Button.Simple.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 16/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit

extension Component.Skin.Button {
    
    public class Simple {
        
        //MARK: - Options -
        
        public struct Options {
            
            public static let `default` = Options()
            public var margins: UIEdgeInsets
            public var border: BorderOptions?
            public var cornerRadius:CGFloat?
            
            init(margins: UIEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16),
                 border: BorderOptions? = (0.5, UIColor(hex: 0xD9D9D9)),
                 cornerRadius:CGFloat? = 8) {
                self.margins = margins
                self.border = border
                self.cornerRadius = cornerRadius
            }
        }
        
        //MARK: - Class Init -
        
        private(set) public var id: String = UUID().uuidString
        private var containerRect: CGRect = .zero
        public var options: Options
        public var backgroundColors: ButtonStateColors
        public var titleAttributes: ButtonStateTitles {
            didSet {
                initialiase()
            }
        }
        private var attributes = [Component.View.Button.State: [NSAttributedString.Key: Any]]()
        private var drawingText = [Component.View.Button.State: String?]()
        public var images: ButtonStateImages
        public var imageSide: Side = .left
        
        required public init(options: Options) {
            self.options = options
            self.backgroundColors = [.normal: (UIColor(hex: 0xffffff), UIColor(hex: 0xffffff)),
                                     .highlighted: (UIColor(hex: 0x6EDC5F), UIColor(hex: 0x6EDC5F)),
                                     .disabled: (UIColor(hex: 0x45005F), UIColor(hex: 0x45005F)),
                                     .selected: (UIColor(hex: 0x6EDC5F), UIColor(hex: 0x6EDC5F))]
            self.titleAttributes = [.normal: (nil, UIColor.black, UIFont(name: "HelveticaNeue-Light", size: 16) ?? UIFont.systemFont(ofSize: 16)),
                                    .highlighted: (nil, nil, nil),
                                    .disabled: (nil, nil, nil),
                                    .selected: (nil, nil, nil)]
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
                        .font: self.titleAttributes[state]?.font ?? self.titleAttributes[.normal]?.font ?? UIFont(name: "HelveticaNeue-Light", size: 16) ?? UIFont.systemFont(ofSize: 16),
                        .foregroundColor: self.titleAttributes[state]?.color ?? self.titleAttributes[.normal]?.color ?? UIColor.black
                    ]}()
                
                let text = titleAttributes[state]?.title ?? titleAttributes[.normal]?.title
                drawingText[state] = text
            }
        }
    }
}

//MARK: - ComponentButtonSkinable

extension Component.Skin.Button.Simple: ComponentButtonSkinable {
    
    public func frameDidChange(rect: CGRect) {
        containerRect = rect
        initialiase()
    }
    
    private func sizeThatFits() -> CGSize {
        var size = CGSize(width: 44, height: 44)
        Component.View.Button.State.all.forEach { state in
            var textSize: CGSize = .zero
            if let drawingText = drawingText[state],
                let text = drawingText,
                let attributes = attributes[state] {
                
                let textWidth = ceil(text.size(withAttributes: attributes).width)
                textSize.width = textWidth
            }
            var imageSize: CGSize = .zero
            if let image = images[state]?.image{
                imageSize.width = image.size.width
            }
            if textSize.width > 0 && imageSize.width > 0 {
                size.width = max(size.width, textSize.width + imageSize.width + 8 + options.margins.horizontalMargins)
            } else if textSize.width > 0 {
                size.width = max(size.width, textSize.width + options.margins.horizontalMargins)
            } else if imageSize.width > 0 {
                size.width = max(size.width, imageSize.width + options.margins.horizontalMargins)
            }
        }
        return size
    }
    
    public func preferedSize() -> CGSize {
        return sizeThatFits()
    }
}

//MARK: - Drawing -

extension Component.Skin.Button.Simple {
    
    public func draw(rect: CGRect, stateTransition: ButtonTransitionStates, stateProgress: CGFloat) {
        guard let from = backgroundColors[stateTransition.from] ?? nil,
            let to = backgroundColors[stateTransition.to] ?? nil
            else { return }
        
        let topColor = from.top.interpolateColorTo(to.top, fraction: stateProgress)
        let bottomColor = from.bottom.interpolateColorTo(to.bottom, fraction: stateProgress)
        Drawing.linearGradient(in: rect,
                               colors: [topColor, bottomColor],
                               locations: [0.0, 1.0],
                               startPoint: .zero,
                               endPoint: CGPoint(x: 0, y: rect.height),
                               cornerRadius: options.cornerRadius)
        
        if let border = options.border {
            let outterBorderRect = rect
            let innerBorderRect = rect.insetBy(dx: border.width.double, dy: border.width.double)
            border.color.setFill()
            if let cornerRadius = options.cornerRadius {
                let clipPath = UIBezierPath(roundedRect: innerBorderRect, cornerRadius: cornerRadius)
                let fillPath = UIBezierPath(roundedRect: outterBorderRect, cornerRadius: cornerRadius)
                let path = fillPath.substract(path: clipPath)
                path.fill()
            } else {
                let clipPath = UIBezierPath(rect: innerBorderRect)
                let fillPath = UIBezierPath(rect: outterBorderRect)
                let path = fillPath.substract(path: clipPath)
                path.fill()
            }
        }
        
        let state = stateTransition.to
        var textRect: CGRect = .zero
        if let drawingText = drawingText[state],
            let text = drawingText,
            let attributes = attributes[state] {
            
            let textSize = text.size(withAttributes: attributes)
            textRect.size = CGSize(width: ceil(textSize.width), height: ceil(textSize.height))
            textRect.origin.y = (containerRect.inset(by: options.margins).height - textRect.height).half + options.margins.top
        }
        var imageRect: CGRect = .zero
        if let image = images[state]?.image{
            imageRect.size = image.size
            imageRect.origin.y = (containerRect.height - imageRect.height).half
        }
        var size: CGSize = .zero
        if textRect.width > 0 && imageRect.width > 0 {
            size.width = textRect.width + imageRect.width + 8
            switch imageSide {
            case .left:
                imageRect.origin.x = (containerRect.width - size.width).half
                textRect.origin.x = imageRect.maxX + 8
            case .right:
                textRect.origin.x = (containerRect.width - size.width).half
                imageRect.origin.x = textRect.maxX + 8
            }
        } else if textRect.width > 0 {
            size.width = textRect.width
            textRect.origin.x = (containerRect.width - size.width).half
        } else if imageRect.width > 0 {
            size.width = imageRect.width
            imageRect.origin.x = (containerRect.width - size.width).half
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


