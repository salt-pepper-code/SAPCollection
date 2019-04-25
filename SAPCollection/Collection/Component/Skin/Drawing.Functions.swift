//
//  Drawing.Functions.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 26/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit

public enum Drawing {

    public static func shadow(for path: UIBezierPath, shadow: ShadowOptions, colorFill: UIColor = .white) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        context.setShadow(offset: shadow.offset, blur: shadow.blur, color: shadow.color.cgColor)
        colorFill.setFill()
        path.fill()
        context.restoreGState()
    }
    
    public static func innnerShadow(contextRect: CGRect, in path: UIBezierPath, innnerShadow: ShadowOptions) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let outPath = UIBezierPath(rect: contextRect)
        //Create the shadow from the filling of the outside
        context.saveGState()
        context.setShadow(offset: innnerShadow.offset, blur: innnerShadow.blur, color: innnerShadow.color.cgColor)
        UIColor.white.setFill()
        let path = outPath.substract(path: path)
        path.fill();
        context.restoreGState()
        
        //Clear out outter path
        context.saveGState()
        UIColor.white.setFill()
        context.setBlendMode(.clear)
        path.fill()
        context.restoreGState()
    }
    
    public static func fill(path: UIBezierPath, mask: UIBezierPath?, colorFill: UIColor) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        if let mask = mask {
            context.saveGState()
            colorFill.setFill()
            context.addPath(mask.cgPath)
            context.clip()
            path.fill()
            context.restoreGState()
        } else {
            colorFill.setFill()
            path.fill()
        }
    }
    
    public static func linear(gradient: CGGradient, start: CGPoint, end: CGPoint, mask: UIBezierPath?) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        if let mask = mask {
            context.addPath(mask.cgPath)
            context.clip()
        }
        context.drawLinearGradient(gradient, start: start, end: end, options: [])
        context.restoreGState()
    }
    
    public static func shapedLinearGradient(path: UIBezierPath, colors: [UIColor], locations: [CGFloat], startPoint: CGPoint, endPoint: CGPoint) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = colors.map { $0.cgColor } as CFArray
        
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations),
            let context = UIGraphicsGetCurrentContext()
            else { return }
        
        context.saveGState()
        context.addPath(path.cgPath)
        context.clip()
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        context.restoreGState()
    }
    
    public static func linearGradient(in rect: CGRect, colors: [UIColor], locations: [CGFloat], startPoint: CGPoint, endPoint: CGPoint, cornerRadius: CGFloat? = nil) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = colors.map { $0.cgColor } as CFArray
        
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations),
            let context = UIGraphicsGetCurrentContext()
            else { return }
        
        context.saveGState()
        if let cornerRadius = cornerRadius {
            let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            context.addPath(path.cgPath)
        } else {
            context.addRect(rect)
        }
        context.clip()
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        context.restoreGState()
    }
    
    public static func radialGradient(colors: [UIColor], locations: [CGFloat], center: CGPoint, radius: CGFloat) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = colors.map { $0.cgColor } as CFArray
        
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations),
            let context = UIGraphicsGetCurrentContext()
            else { return }
        
        context.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: radius, options: [])
    }
    
    public static func bevelEffect(gradientFill: CGGradient?, path: UIBezierPath, lightAlpha: CGFloat = 1, shadowAlpha: CGFloat = 0.1) {
        bevelEmbossEffect(gradientFill: gradientFill, path: path, lightAlpha: lightAlpha, shadowAlpha: shadowAlpha, isEmboss: false)
    }
    
    public static func embossEffect(gradientFill: CGGradient?, path: UIBezierPath, lightAlpha: CGFloat = 1, shadowAlpha: CGFloat = 0.1) {
        bevelEmbossEffect(gradientFill: gradientFill, path: path, lightAlpha: lightAlpha, shadowAlpha: shadowAlpha, isEmboss: true)
    }
    
    private static func bevelEmbossEffect(gradientFill: CGGradient?, path: UIBezierPath, lightAlpha: CGFloat, shadowAlpha: CGFloat, isEmboss: Bool) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let rect = path.bounds
        
        if let gradientFill = gradientFill {
            context.saveGState()
            context.addPath(path.cgPath)
            context.clip()
            context.drawLinearGradient(gradientFill,
                                       start: rect.origin,
                                       end: CGPoint(x: rect.origin.x, y: rect.maxY),
                                       options: [])
            context.restoreGState()
        }
        
        let lightingPath = UIBezierPath(cgPath: path.cgPath)
        lightingPath.apply(CGAffineTransform(translationX: 0, y: isEmboss ? -1 : 1))
        
        let lightingMask = isEmboss ? path.removeTopHalf() : path.removeBottomHalf()
        
        let newlightingPath = path.substract(path: lightingPath)
        context.saveGState()
        context.addPath(lightingMask.cgPath)
        context.clip()
        UIColor.white.withAlphaComponent(lightAlpha).setFill()
        newlightingPath.fill()
        context.restoreGState()
        
        let shadowPath = UIBezierPath(cgPath: path.cgPath)
        shadowPath.apply(CGAffineTransform(translationX: 0, y: isEmboss ? 2 : -2))
        
        let shadowMask = isEmboss ? path.removeBottomHalf() : path.removeTopHalf()
        
        let newShadowPath = path.substract(path: shadowPath)
        context.saveGState()
        context.addPath(shadowMask.cgPath)
        context.clip()
        UIColor.black.withAlphaComponent(shadowAlpha).setFill()
        newShadowPath.fill()
        context.restoreGState()
    }
}
