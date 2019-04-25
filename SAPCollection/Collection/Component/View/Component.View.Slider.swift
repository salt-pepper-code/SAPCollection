//
//  Component.View.Slider.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 18/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit
import MKTween

public protocol ComponentSliderSkinable: Skinable {
    func handleCenters() -> RangePointPair
    func draw(rect: CGRect, handlePosition: CGPoint, progressRatio: CGPoint, value: CGFloat)
}

public protocol ComponentSliderDelegate: class {
    func valueChanged(slider: Component.View.Slider, value: CGFloat)
}

extension Component.View {
    
    public class Slider: UIView, Nameable {
        
        public typealias Delegate = ComponentSliderDelegate
        
        public weak var delegate: Delegate?
        
        private(set) public var id: String = UUID().uuidString
        public var name = "Component.View.Slider"
        
        private var previousBounds: CGRect = .zero
        private var handlePosition: CGPoint = .zero
        private var handleCenters: RangePointPair = (.zero, .zero)
        
        public let skin: ComponentSliderSkinable
        public let animation: (duration: TimeInterval, timing: Timing)
        
        private(set) public var value: CGFloat = 0 {
            didSet {
                delegate?.valueChanged(slider: self, value: value)
            }
        }
        private(set) public var minimumValue: CGFloat = 0
        private(set) public var maximumValue: CGFloat = 1
        
        public required init(skin: ComponentSliderSkinable, animation: (duration: TimeInterval, timing: Timing) = (0.7, .quadInOut)) {
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
        
        private func progressRatio() -> CGPoint {
            return CGPoint(x: (value - minimumValue) / (maximumValue - minimumValue),
                           y: (value - minimumValue) / (maximumValue - minimumValue))
        }
        
        private func calculateHandlePosition() {
            if handleCenters.min.x < handleCenters.max.x {
                handlePosition.x = ((handleCenters.max.x - handleCenters.min.x) * progressRatio().x) + handleCenters.min.x
            }
            if handleCenters.min.y < handleCenters.max.y {
                handlePosition.y = ((handleCenters.max.y - handleCenters.min.y) * progressRatio().y) + handleCenters.min.y
            }
        }
    }
}

//MARK: - Gestures

extension Component.View.Slider {
    
    private func locationRatio(for location: CGPoint) -> CGPoint {
        return CGPoint(x: (location.x - handleCenters.min.x) / (handleCenters.max.x - handleCenters.min.x),
                       y: (location.y - handleCenters.min.y) / (handleCenters.max.y - handleCenters.min.y))
    }
    
    @objc private func didPan(sender: UIPanGestureRecognizer) {
        let location = sender.location(in: self)
        var ratio: CGFloat = 0
        switch location.x {
        case handleCenters.min.x...handleCenters.max.x where handleCenters.min.x < handleCenters.max.x:
            ratio = locationRatio(for: location).x
        case ...handleCenters.min.x where handleCenters.min.x < handleCenters.max.x:
            ratio = locationRatio(for: handleCenters.min).x
        case handleCenters.max.x... where handleCenters.min.x < handleCenters.max.x:
            ratio = locationRatio(for: handleCenters.max).x
        default:
            break
        }
        switch location.y {
        case handleCenters.min.y...handleCenters.max.y where handleCenters.min.y < handleCenters.max.y:
            ratio = locationRatio(for: location).y
        case ...handleCenters.min.y where handleCenters.min.y < handleCenters.max.y:
            ratio = locationRatio(for: handleCenters.min).y
        case handleCenters.max.y... where handleCenters.min.y < handleCenters.max.y:
            ratio = locationRatio(for: handleCenters.max).y
        default:
            break
        }
        set(value: (ratio * (maximumValue - minimumValue)) + minimumValue)
    }
}

//MARK: - Animation

extension Component.View.Slider {
    
    public func animate(to value: CGFloat, delay: TimeInterval = 0) {
        Tween.shared.removePeriod(by: "\(id)")
        let period = Period(start: self.value, end: value, duration: animation.duration, delay: delay).set(update: { [weak self] period in
            self?.set(value: period.progress)
        }).set(timingMode: animation.timing).set(name: id)
        Tween.shared.add(period: period)
    }
}

//MARK: - Public methods

extension Component.View.Slider {
    
    public func set(value: CGFloat) {
        self.value = value.clamped(to: minimumValue...maximumValue)
        calculateHandlePosition()
        setNeedsDisplay()
    }
    
    public func set(minimumValue: CGFloat, maximumValue: CGFloat) {
        self.minimumValue = minimumValue.clamped(to: -CGFloat.greatestFiniteMagnitude...maximumValue)
        self.maximumValue = maximumValue.clamped(to: minimumValue...CGFloat.greatestFiniteMagnitude)
        set(value: value)
    }
}

//MARK: - Drawing

extension Component.View.Slider {
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard rect.width != 0 else { return }
        
        if previousBounds != rect {
            previousBounds = rect
            skin.frameDidChange(rect: rect)
            handleCenters = skin.handleCenters()
            handlePosition = handleCenters.min
            calculateHandlePosition()
        }
        
        (backgroundColor ?? UIColor.clear).setFill()
        UIRectFill(rect)
        
        skin.draw(rect: rect, handlePosition: handlePosition, progressRatio: progressRatio(), value: value)
    }
}

