//
//  Convenient.Functions.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 26/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit

public func gradientUIColors(gradientColor: GradientVerticalColorPair) -> [UIColor] {
    return [gradientColor.top, gradientColor.bottom]
}

public func gradientCFColors(gradientColor: GradientVerticalColorPair) -> CFArray {
    return [gradientColor.top, gradientColor.bottom].map { $0.cgColor } as CFArray
}

public func interpolate(from: ShadowOptions, to: ShadowOptions, fraction: CGFloat) -> ShadowOptions {
    let f = fraction.clamped(to: 0...1)
    
    switch f {
    case 0:
        return from
    case 1:
        return to
    default:
        break
    }
    
    let offset = from.offset + (to.offset - from.offset) * f
    let blur = from.blur + (to.blur - from.blur) * f
    let color = from.color.interpolateColorTo(to.color, fraction: f)
    
    return (offset, blur, color)
}
