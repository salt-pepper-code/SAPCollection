//
//  Component.View.Switch.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 16/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit
import MKTween

public protocol ComponentSwitchSkinable: Skinable {
    func handleCenters() -> StatePointPair
    func draw(rect: CGRect, handlePosition: CGPoint, progressRatio: CGPoint)
}

public protocol ComponentSwitchDelegate: class {
    func stateChanged(switch: Component.View.Switch, on: Bool)
}

extension Component.View {
    
    public class Switch: UIView, Nameable {
                
        public typealias Delegate = ComponentSwitchDelegate
    
        public weak var delegate: Delegate?
        
        private(set) public var id: String = UUID().uuidString
        public var name = "Component.View.Switch"
        
        private var previousBounds: CGRect = .zero
        public let skin: ComponentSwitchSkinable
        private var handlePosition: CGPoint = .zero
        private var handleCenters: StatePointPair = (.zero, .zero)
        public let animation: (duration: TimeInterval, timing: Timing)
        
        private(set) public var isOn: Bool = false {
            didSet {
                delegate?.stateChanged(switch: self, on: isOn)
            }
        }
        
        public required init(skin: ComponentSwitchSkinable, animation: (duration: TimeInterval, timing: Timing) = (0.3, .quadInOut)) {
            self.skin = skin
            self.animation = animation
            super.init(frame: .zero)
            initialize()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func initialize() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            addGestureRecognizer(tapGesture)
            
            backgroundColor = .clear
        }
    }
}

//MARK: - Gestures

extension Component.View.Switch {
    
    @objc private func didTap(sender: UITapGestureRecognizer) {
        animate(to: isOn ? handleCenters.off : handleCenters.on)
        isOn = !isOn
    }
}

//MARK: - Animation

extension Component.View.Switch {
    
    private func animate(to: CGPoint) {
        Tween.shared.removePeriod(by: "\(id)")
        let period = Period(start: handlePosition, end: to, duration: animation.duration).set(update: { [weak self] period in
            self?.handlePosition = period.progress
            self?.setNeedsDisplay()
        }).set(timingMode: animation.timing).set(name: id)
        Tween.shared.add(period: period)
    }
}


//MARK: - Public methods

extension Component.View.Switch {
    
    public func set(on: Bool) {
        isOn = on
        animate(to: isOn ? handleCenters.off : handleCenters.on)
    }
}

//MARK: - Drawing

extension Component.View.Switch {
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard rect.width != 0 else { return }
        
        if previousBounds != rect {
            previousBounds = rect
            skin.frameDidChange(rect: rect)
            handleCenters = skin.handleCenters()
            handlePosition = handleCenters.off
        }

        UIColor.clear.setFill()
        UIRectFill(rect)

        let progressRatio = CGPoint(x: (handlePosition.x - handleCenters.off.x) / (handleCenters.on.x - handleCenters.off.x),
                                    y: (handlePosition.y - handleCenters.off.y) / (handleCenters.on.y - handleCenters.off.y))
        skin.draw(rect: rect, handlePosition: handlePosition, progressRatio: progressRatio)
    }
}
