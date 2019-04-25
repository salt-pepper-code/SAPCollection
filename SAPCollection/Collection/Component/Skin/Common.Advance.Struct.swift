//
//  Common.Struct.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 24/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit

public struct OutterBevel {
    public var gradientColor: GradientVerticalColorPair
    public var innnerShadow: ShadowOptions?
    
    public init(gradientColor: GradientVerticalColorPair, innnerShadow: ShadowOptions?) {
        self.gradientColor = gradientColor
        self.innnerShadow = innnerShadow
    }
    public func gradientUIColors() -> [UIColor] {
        return [gradientColor.top, gradientColor.bottom]
    }
    public func gradientCFColors() -> CFArray {
        return [gradientColor.top, gradientColor.bottom].map { $0.cgColor } as CFArray
    }
}

public struct Handle {
    public var gradientColor: GradientVerticalColorPair
    public var shadow: ShadowOptions?
    
    public init(gradientColor: GradientVerticalColorPair, shadow: ShadowOptions?) {
        self.gradientColor = gradientColor
        self.shadow = shadow
    }
    public func gradientUIColors() -> [UIColor] {
        return [gradientColor.top, gradientColor.bottom]
    }
    public func gradientCFColors() -> CFArray {
        return [gradientColor.top, gradientColor.bottom].map { $0.cgColor } as CFArray
    }
}

public struct HandleBevel {
    public var gradientColor: GradientVerticalColorPair
    
    public init(gradientColor: GradientVerticalColorPair) {
        self.gradientColor = gradientColor
    }
    public func gradientUIColors() -> [UIColor] {
        return [gradientColor.top, gradientColor.bottom]
    }
    public func gradientCFColors() -> CFArray {
        return [gradientColor.top, gradientColor.bottom].map { $0.cgColor } as CFArray
    }
}

public struct NumericText {
    public var font: UIFont
    public var color: UIColor
    public var fractionDigits: (minimumFractionDigits: Int, maximumFractionDigits: Int)
    public var unit: String?
    public init(font: UIFont, color: UIColor, fractionDigits: (minimumFractionDigits: Int, maximumFractionDigits: Int) = (0, 0), unit: String? = nil) {
        self.font = font
        self.color = color
        self.fractionDigits = fractionDigits
        self.unit = unit
    }
}
