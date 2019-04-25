//
//  Numbers+Extension.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 15/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit

extension NumberFormatter {
    public func string(value: CGFloat, fractionDigits: (minimumFractionDigits: Int, maximumFractionDigits: Int)) -> String {
        self.minimumFractionDigits = fractionDigits.minimumFractionDigits
        self.maximumFractionDigits = fractionDigits.maximumFractionDigits
        return self.string(for: value) ?? "\(value)"
    }
}

extension CGFloat {
    public var cgsize: CGSize {
        return CGSize(width: self, height: self)
    }
    public var half: CGFloat {
        return self / 2
    }
    public var double: CGFloat {
        return self * 2
    }
    public static var pi2: CGFloat {
        return .pi * 2
    }
    public func string(fractionDigits: (minimumFractionDigits: Int, maximumFractionDigits: Int)) -> String {
        return NumberFormatter().string(value: self, fractionDigits: fractionDigits)
    }
}

public func roundf(_ value: CGFloat) -> CGFloat {
    return CGFloat(roundf(Float(value)))
}

extension Int {
    public var cgfloat: CGFloat {
        return CGFloat(self)
    }
}

extension BinaryInteger {
    public var degreesToRadians: CGFloat { return CGFloat(self) * .pi / 180 }
}

extension FloatingPoint {
    public var degreesToRadians: Self { return self * .pi / 180 }
    public var radiansToDegrees: Self { return self * 180 / .pi }
}
