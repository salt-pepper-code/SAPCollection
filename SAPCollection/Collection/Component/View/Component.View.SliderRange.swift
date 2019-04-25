//
//  Component.View.SliderRange.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 20/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit
import MKTween

public protocol ComponentSliderRangeSkinable: Skinable {
    func handleCenters() -> RangePointPair
    func draw(rect: CGRect, handlePositions: SliderRangePointPair, progressRatios: SliderRangePointPair, values: SliderRangeValuePair)
}

public protocol ComponentSliderRangeDelegate: class {
    func valueChanged(slider: Component.View.SliderRange, values: SliderRangeValuePair)
}

extension Component.View {
        
    public class SliderRange: UIView, Nameable {
        
        public typealias Delegate = ComponentSliderRangeDelegate
        
        public weak var delegate: Delegate?
        
        private(set) public var id: String = UUID().uuidString
        public var name = "Component.View.SliderRange"
        
        private var previousBounds: CGRect = .zero
        private var handlePositions: SliderRangePointPair = (.zero, .zero)
        private var handleCenters: RangePointPair = (.zero, .zero)
        
        public let skin: ComponentSliderRangeSkinable
        public let animation: (duration: TimeInterval, timing: Timing)
        
        private(set) public var values: SliderRangeValuePair = (0, 0) {
            didSet {
                delegate?.valueChanged(slider: self, values: values)
            }
        }
        private(set) public var minimumValue: CGFloat = 0
        private(set) public var maximumValue: CGFloat = 1
        
        public required init(skin: ComponentSliderRangeSkinable, animation: (duration: TimeInterval, timing: Timing) = (0.7, .quadInOut)) {
            self.skin = skin
            self.animation = animation
            super.init(frame: .zero)
            initialize()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func initialize() {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan))
            panGesture.maximumNumberOfTouches = 1
            panGesture.minimumNumberOfTouches = 1
            addGestureRecognizer(panGesture)
            
            backgroundColor = .clear
        }
        
        private func progressRatios() -> SliderRangePointPair {
            return (CGPoint(x: (values.left - minimumValue) / (maximumValue - minimumValue),
                            y: (values.left - minimumValue) / (maximumValue - minimumValue)),
                    CGPoint(x: (values.right - minimumValue) / (maximumValue - minimumValue),
                            y: (values.right - minimumValue) / (maximumValue - minimumValue)))
        }
        
        private func calculateHandlePositions() {
            if handleCenters.min.x < handleCenters.max.x {
                handlePositions.left.x = ((handleCenters.max.x - handleCenters.min.x) * progressRatios().left.x) + handleCenters.min.x
                handlePositions.right.x = ((handleCenters.max.x - handleCenters.min.x) * progressRatios().right.x) + handleCenters.min.x
            }
            if handleCenters.min.y < handleCenters.max.y {
                handlePositions.left.y = ((handleCenters.max.y - handleCenters.min.y) * progressRatios().left.y) + handleCenters.min.y
                handlePositions.right.y = ((handleCenters.max.y - handleCenters.min.y) * progressRatios().right.y) + handleCenters.min.y
            }
        }
    }
}

//MARK: - Gestures

extension Component.View.SliderRange {
    
    private func locationRatio(for location: CGPoint) -> CGPoint {
        return CGPoint(x: (location.x - handleCenters.min.x) / (handleCenters.max.x - handleCenters.min.x),
                       y: (location.y - handleCenters.min.y) / (handleCenters.max.y - handleCenters.min.y))
    }
    
    @objc private func didPan(sender: UIPanGestureRecognizer) {
        let location = sender.location(in: self)
        var ratio: CGFloat = 0
        var isLeft: Bool?
        switch location.x {
        case handleCenters.min.x...handleCenters.max.x where handleCenters.min.x < handleCenters.max.x:
            ratio = locationRatio(for: location).x
            isLeft = abs(location.x - handlePositions.left.x) < abs(location.x - handlePositions.right.x)
        case ...handleCenters.min.x where handleCenters.min.x < handleCenters.max.x:
            ratio = locationRatio(for: handleCenters.min).x
            isLeft = abs(location.x - handlePositions.left.x) < abs(location.x - handlePositions.right.x)
        case handleCenters.max.x... where handleCenters.min.x < handleCenters.max.x:
            ratio = locationRatio(for: handleCenters.max).x
            isLeft = abs(location.x - handlePositions.left.x) < abs(location.x - handlePositions.right.x)
        default:
            break
        }
        switch location.y {
        case handleCenters.min.y...handleCenters.max.y where handleCenters.min.y < handleCenters.max.y:
            ratio = locationRatio(for: location).y
            isLeft = abs(location.y - handlePositions.left.y) < abs(location.y - handlePositions.right.y)
        case ...handleCenters.min.y where handleCenters.min.y < handleCenters.max.y:
            ratio = locationRatio(for: handleCenters.min).y
            isLeft = abs(location.y - handlePositions.left.y) < abs(location.y - handlePositions.right.y)
        case handleCenters.max.y... where handleCenters.min.y < handleCenters.max.y:
            ratio = locationRatio(for: handleCenters.max).y
            isLeft = abs(location.y - handlePositions.left.y) < abs(location.y - handlePositions.right.y)
        default:
            break
        }
        if let isLeft = isLeft {
            if isLeft {
                set(left: (ratio * (maximumValue - minimumValue)) + minimumValue)
            } else {
                set(right: (ratio * (maximumValue - minimumValue)) + minimumValue)
            }
        }
    }
}

//MARK: - Animation

extension Component.View.SliderRange {
    
    public func animate(to values: SliderRangeValuePair, delay: TimeInterval = 0) {
        Tween.shared.removePeriod(by: "\(id)left")
        let leftPeriod = Period(start: self.values.left, end: values.left, duration: animation.duration, delay: delay)
            .set(update: { [weak self] period in
                self?.set(left: period.progress)
            })
            .set(timingMode: animation.timing)
            .set(name: "\(id)left")
        Tween.shared.add(period: leftPeriod)

        Tween.shared.removePeriod(by: "\(id)right")
        let rightPeriod = Period(start: self.values.right, end: values.right, duration: animation.duration, delay: delay)
            .set(update: { [weak self] period in
                self?.set(right: period.progress)
            })
            .set(timingMode: animation.timing)
            .set(name: "\(id)right")
        Tween.shared.add(period: rightPeriod)
    }
}

//MARK: - Public methods

extension Component.View.SliderRange {
    
    public func set(left value: CGFloat) {
        self.values.left = value.clamped(to: minimumValue...values.right)
        calculateHandlePositions()
        setNeedsDisplay()
    }
    
    public func set(right value: CGFloat) {
        self.values.right = value.clamped(to: values.left...maximumValue)
        calculateHandlePositions()
        setNeedsDisplay()
    }
    
    public func set(values: SliderRangeValuePair) {
        self.values.left = values.left.clamped(to: minimumValue...values.right)
        self.values.right = values.right.clamped(to: values.left...maximumValue)
        calculateHandlePositions()
        setNeedsDisplay()
    }
    
    public func set(minimumValue: CGFloat, maximumValue: CGFloat) {
        self.minimumValue = minimumValue.clamped(to: -CGFloat.greatestFiniteMagnitude...maximumValue)
        self.maximumValue = maximumValue.clamped(to: minimumValue...CGFloat.greatestFiniteMagnitude)
        set(values: values)
    }
}

//MARK: - Drawing

extension Component.View.SliderRange {
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard rect.width != 0 else { return }
    
        if previousBounds != rect {
            previousBounds = rect
            skin.frameDidChange(rect: rect)
            handleCenters = skin.handleCenters()
            handlePositions = (handleCenters.min, handleCenters.max)
            calculateHandlePositions()
        }
        
        (backgroundColor ?? UIColor.clear).setFill()
        UIRectFill(rect)
        
        skin.draw(rect: rect, handlePositions: handlePositions, progressRatios: progressRatios(), values: values)
    }
}
