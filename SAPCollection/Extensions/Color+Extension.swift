//
//  Color+Extension.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 15/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import Foundation
import UIKit

public struct ColorComponents {
    public var r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat
}

extension UIColor {

    public convenience init(byteRed: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        self.init(red: CGFloat(byteRed) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha) / 255.0)
    }

    public convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }

    public func interpolateColorTo(_ end: UIColor, fraction: CGFloat) -> UIColor {
        let f = fraction.clamped(to: 0...1)

        switch f {
        case 0:
            return self
        case 1:
            return end
        default:
            break
        }
        
        let c1 = self.getComponents()
        let c2 = end.getComponents()

        let r = c1.r + (c2.r - c1.r) * f
        let g = c1.g + (c2.g - c1.g) * f
        let b = c1.b + (c2.b - c1.b) * f
        let a = c1.a + (c2.a - c1.a) * f

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

    public func blendAlpha(with color: UIColor) -> UIColor {
        let c1 = color.getComponents()
        let c2 = self.getComponents()

        let a = (1 - c1.a) * c2.a + c1.a
        let r = ((1 - c1.a) * c2.a * c2.r + c1.a * c1.r) / a
        let g = ((1 - c1.a) * c2.a * c2.g + c1.a * c1.g) / a
        let b = ((1 - c1.a) * c2.a * c2.b + c1.a * c1.b) / a

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

    public func getComponents() -> ColorComponents {
        if cgColor.numberOfComponents == 2 {
            let cc = cgColor.components!
            return ColorComponents(r: cc[0], g: cc[0], b: cc[0], a: cc[1])
        } else {
            let cc = cgColor.components!
            return ColorComponents(r: cc[0], g: cc[1], b: cc[2], a: cc[3])
        }
    }
    
    public convenience init(hex: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: a.clamped(to: 0...1)
        )
    }
    public convenience init(string hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    public convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r.clamped(to: 0...255) / 255, green: g.clamped(to: 0...255) / 255, blue: b.clamped(to: 0...255) / 255, alpha: 1)
    }
    
    public convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        self.init(red: r.clamped(to: 0...255) / 255, green: g.clamped(to: 0...255) / 255, blue: b.clamped(to: 0...255) / 255, alpha: a.clamped(to: 0...1))
    }
}
