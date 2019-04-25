//
//  CoreGraphics.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 15/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit

extension CGPoint {
    
    public func offset(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + dx, y: self.y + dy)
    }
    
    public static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

extension CGRect {
    
    public var center: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
    
    public func horizontalSplit(ratio: CGFloat) -> (first: CGRect, second: CGRect) {
        let width = self.width * ratio
        return (CGRect(x: self.origin.x, y: self.origin.y, width: width, height: self.height),
                CGRect(x: self.origin.x + width, y: self.origin.y, width: self.width - width, height: self.height))
    }
    
    public func verticalSplit(ratio: CGFloat) -> (first: CGRect, second: CGRect) {
        let height = self.height * ratio
        return (CGRect(x: self.origin.x, y: self.origin.y, width: width, height: height),
                CGRect(x: self.origin.x, y: self.origin.y + height, width: self.width, height: self.height - height))
    }
    
    public static func / (lhs: CGRect, ratio: CGFloat) -> CGRect {
        return CGRect(x: lhs.origin.x, y: lhs.origin.y, width: lhs.size.width / ratio, height: lhs.size.height / ratio)
    }
}

extension CGSize {
    
    public static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    public static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    
    public static func * (lhs: CGSize, scalar: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * scalar, height: lhs.height * scalar)
    }
}

extension UIBezierPath {
    
    public convenience init(circleCenter: CGPoint, radius: CGFloat) {
        self.init(arcCenter: circleCenter, radius: radius, startAngle: 0, endAngle: .pi2, clockwise: true)
    }
    
    public static func - (lhs: UIBezierPath, rhs: UIBezierPath) -> UIBezierPath {
        let path = UIBezierPath(cgPath: lhs.cgPath)
        path.append(rhs.reversing())
        return path
    }
    
    public func substract(path: UIBezierPath) -> UIBezierPath {
        return self - path
    }
    
    public static func + (lhs: UIBezierPath, rhs: UIBezierPath) -> UIBezierPath {
        let path = UIBezierPath(cgPath: lhs.cgPath)
        path.append(rhs)
        return path
    }
    
    public func union(path: UIBezierPath) -> UIBezierPath {
        return self + path
    }
    
    public func removeBottomHalf() -> UIBezierPath {
        let topRect = self.bounds.verticalSplit(ratio: 0.5).first
        let topHalf = UIBezierPath()
        var firstPoint = true
        let compare: (_ maxY: CGFloat, _ yPos: CGFloat) -> Bool = { maxY, yPos in
            return round(maxY * 1000) >= round(yPos * 1000)
        }
        self.cgPath.forEach { (element) in
            switch element {
            case .move(to: let point), .line(let point):
                if compare(topRect.maxY, point.y) && firstPoint {
                    topHalf.move(to: point)
                    firstPoint = false
                } else if compare(topRect.maxY, point.y) {
                    topHalf.addLine(to: point)
                } else if firstPoint {
                    topHalf.move(to: CGPoint(x: point.x, y: topRect.maxY))
                    firstPoint = false
                } else {
                    topHalf.addLine(to: CGPoint(x: point.x, y: topRect.maxY))
                }
            case .quadCurve(let point, let via):
                if compare(topRect.maxY, point.y) {
                    let via = CGPoint(x: via.x, y: min(via.y, topRect.maxY))
                    topHalf.addQuadCurve(to: point, controlPoint: via)
                } else if firstPoint {
                    topHalf.move(to: CGPoint(x: point.x, y: topRect.maxY))
                    firstPoint = false
                } else {
                    topHalf.addLine(to: CGPoint(x: point.x, y: topRect.maxY))
                }
            case .cubicCurve(let point, let v1, let v2):
                if compare(topRect.maxY, point.y) {
                    let v1 = CGPoint(x: v1.x, y: min(v1.y, topRect.maxY))
                    let v2 = CGPoint(x: v2.x, y: min(v2.y, topRect.maxY))
                    topHalf.addCurve(to: point, controlPoint1: v1, controlPoint2: v2)
                } else if firstPoint {
                    topHalf.move(to: CGPoint(x: point.x, y: topRect.maxY))
                    firstPoint = false
                } else {
                    topHalf.addLine(to: CGPoint(x: point.x, y: topRect.maxY))
                }
            case .close:
                topHalf.close()
            }
        }
        return topHalf
    }
    
    public func removeTopHalf() -> UIBezierPath {
        let bottomRect = self.bounds.verticalSplit(ratio: 0.5).second
        let bottomHalf = UIBezierPath()
        var firstPoint = true
        let compare: (_ minY: CGFloat, _ yPos: CGFloat) -> Bool = { minY, yPos in
            return round(minY * 1000) <= round(yPos * 1000)
        }
        self.cgPath.forEach { (element) in
            switch element {
            case .move(to: let point), .line(let point):
                if compare(bottomRect.minY, point.y) && firstPoint {
                    bottomHalf.move(to: point)
                    firstPoint = false
                } else if compare(bottomRect.minY, point.y) {
                    bottomHalf.addLine(to: point)
                } else if firstPoint {
                    bottomHalf.move(to: CGPoint(x: point.x, y: bottomRect.minY))
                    firstPoint = false
                } else {
                    bottomHalf.addLine(to: CGPoint(x: point.x, y: bottomRect.minY))
                }
            case .quadCurve(let point, let via):
                if compare(bottomRect.minY, point.y) {
                    let via = CGPoint(x: via.x, y: max(via.y, bottomRect.minY))
                    bottomHalf.addQuadCurve(to: point, controlPoint: via)
                } else if firstPoint {
                    bottomHalf.move(to: CGPoint(x: point.x, y: bottomRect.minY))
                    firstPoint = false
                } else {
                    bottomHalf.addLine(to: CGPoint(x: point.x, y: bottomRect.minY))
                }
            case .cubicCurve(let point, let v1, let v2):
                if compare(bottomRect.minY, point.y) {
                    let v1 = CGPoint(x: v1.x, y: max(v1.y, bottomRect.minY))
                    let v2 = CGPoint(x: v2.x, y: max(v2.y, bottomRect.minY))
                    bottomHalf.addCurve(to: point, controlPoint1: v1, controlPoint2: v2)
                } else if firstPoint {
                    bottomHalf.move(to: CGPoint(x: point.x, y: bottomRect.minY))
                    firstPoint = false
                } else {
                    bottomHalf.addLine(to: CGPoint(x: point.x, y: bottomRect.minY))
                }
            case .close:
                bottomHalf.close()
            }
        }
        return bottomHalf
    }
}

extension UIEdgeInsets {
    
    public var horizontalMargins: CGFloat {
        return self.left + self.right
    }
    
    public var verticalMargins: CGFloat {
        return self.top + self.bottom
    }
}

private func pathApply(_ path: CGPath, body: @escaping @convention(block) (CGPathElement) -> Void) {
    typealias PathApplier = @convention(block) (CGPathElement) -> Void
    let callback: @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CGPathElement>) -> Void = { (info, element) in
        let block = unsafeBitCast(info, to: PathApplier.self)
        block(element.pointee)
    }
    let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
    path.apply(info: unsafeBody, function: unsafeBitCast(callback, to: CGPathApplierFunction.self))
}

public enum PathElement {
    case move(to: CGPoint)
    case line(to: CGPoint)
    case quadCurve(to: CGPoint, via: CGPoint)
    case cubicCurve(to: CGPoint, v1: CGPoint, v2: CGPoint)
    case close
}

public extension CGPath {
    
    func forEach(_ fn: @escaping (PathElement) -> Void) {
        pathApply(self) { element in
            let points = element.points
            switch (element.type) {
            case .moveToPoint:
                fn(.move(to: points[0]))
            case .addLineToPoint:
                fn(.line(to: points[0]))
            case .addQuadCurveToPoint:
                fn(.quadCurve(to: points[1], via: points[0]))
            case .addCurveToPoint:
                fn(.cubicCurve(to: points[2], v1: points[0], v2: points[1]))
            case .closeSubpath:
                fn(.close)
            @unknown default:
                break
            }
        }
    }
}
