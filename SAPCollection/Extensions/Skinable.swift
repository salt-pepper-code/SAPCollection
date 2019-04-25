//
//  Skinable.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 16/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit

public protocol Nameable {
    var id: String { get }
    var name: String { get set }
}

public protocol Skinable {
    var id: String { get }
    func preferedSize() -> CGSize
    func frameDidChange(rect: CGRect)
}

public enum Side {
    case left
    case right
}

public typealias HorizontalMargin = (left: CGFloat, right: CGFloat)

public typealias GradientVerticalColorPair = (top: UIColor, bottom: UIColor)

public typealias StateColorPair = (off: UIColor, on: UIColor)
public typealias StatePointPair = (off: CGPoint, on: CGPoint)

public typealias RangeColorPair = (min: UIColor, max: UIColor)
public typealias RangePointPair = (min: CGPoint, max: CGPoint)

public typealias SliderRangePointPair = (left: CGPoint, right: CGPoint)
public typealias SliderRangeValuePair = (left: CGFloat, right: CGFloat)
public typealias SliderRangeBezierPair = (left: UIBezierPath, right: UIBezierPath)

public typealias ShadowOptions = (offset: CGSize, blur: CGFloat, color: UIColor)

public typealias BorderOptions = (width: CGFloat, color: UIColor)

public typealias ButtonTransitionStates = (from: Component.View.Button.State, to: Component.View.Button.State)
public typealias ButtonStateColors = [Component.View.Button.State: GradientVerticalColorPair?]
public typealias ButtonStateTitles = [Component.View.Button.State: (title: String?, color: UIColor?, font: UIFont?)]
public typealias ButtonStateImages = [Component.View.Button.State: (image: UIImage?, tintColor: UIColor?)]
