//
//  Component.View.Button.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 22/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit
import MKTween

public protocol ComponentButtonSkinable: Skinable {
    var backgroundColors: ButtonStateColors { get set }
    var titleAttributes: ButtonStateTitles { get set }
    var images: ButtonStateImages { get set }
    func draw(rect: CGRect, stateTransition: ButtonTransitionStates, stateProgress: CGFloat)
}

public protocol ComponentButtonDelegate: AnyObject {
    func touchDown(sender: Component.View.Button)
    func touchUpInside(sender: Component.View.Button)
    func touchUpOutside(sender: Component.View.Button)
    func didSelect(sender: Component.View.Button)
}

extension Component.View {
    
    public class Button: UIView, Nameable {
        
        public enum State: String {
            case normal
            case highlighted
            case disabled
            case selected
            static let all: [State] = [.normal, .highlighted, .disabled, .selected]
        }
        
        public typealias Delegate = ComponentButtonDelegate
        
        public weak var delegate: Delegate?
        
        private(set) public var id: String = UUID().uuidString
        public var name = "Component.View.Button"
        public var allowedState = State.all
        
        private var widthConstraints: NSLayoutConstraint?
        private var heightConstraints: NSLayoutConstraint?
        public var autoresizing: Bool = false {
            didSet {
                widthConstraints.map { removeConstraint($0) }
                heightConstraints.map { removeConstraint($0) }
                setupConstraints()
                setNeedsDisplay()
            }
        }
        
        private var previousBounds: CGRect = .zero
        public var skin: ComponentButtonSkinable {
            didSet {
                setupConstraints()
                setNeedsDisplay()
            }
        }
        public let animation: (duration: TimeInterval, timing: Timing)?
        
        public var isEnabled: Bool = true {
            didSet {
                guard allowedState.contains(.disabled) else { return }
                state = isEnabled ? .normal : .disabled
            }
        }
        
        public var isSelected: Bool = true {
            didSet {
                guard allowedState.contains(.selected) else { return }
                state = isSelected ? .selected : (isEnabled ? .normal : .disabled)
            }
        }
        
        private(set) public var state: State = .normal {
            didSet {
                guard oldValue != state else { return }
                if stateProgress == 1 {
                    previousState = oldValue
                }
                prepareTransition()
                if state == .selected {
                    delegate?.didSelect(sender: self)
                }
            }
        }
        internal var previousState: State = .normal
        internal var stateProgress: CGFloat = 0
        
        public required init(skin: ComponentButtonSkinable, animation: (duration: TimeInterval, timing: Timing)? = (0.3, .quadInOut)) {
            self.skin = skin
            self.animation = animation
            super.init(frame: .zero)
            initialize()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func initialize() {
            backgroundColor = .clear
            
            let touchDownGesture = TouchDownGestureRecognizer(target: self, action: #selector(touch))
            addGestureRecognizer(touchDownGesture)
        }
        
        private func setupConstraints() {
            guard autoresizing else { return }
            let size = skin.preferedSize()
            if let widthConstraints = widthConstraints, let heightConstraints = heightConstraints {
                widthConstraints.constant = size.width
                heightConstraints.constant = size.height
            } else {
                let width = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: size.width)
                let height = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: size.height)
                addConstraint(width)
                addConstraint(height)
                widthConstraints = width
                heightConstraints = height
            }
        }
        
        private func prepareTransition() {
            guard previousState != state else { return }
            guard let animation = animation else {
                stateProgress = 1
                setNeedsDisplay()
                return
            }
            stateProgress = stateProgress == 1 ? 0 : stateProgress
            
            Tween.shared.removePeriod(by: "\(id)")
            let period = Period(start: stateProgress, end: 1, duration: animation.duration, delay: 0)
                .set(update: { [weak self] period in
                    self?.stateProgress = period.progress
                    self?.setNeedsDisplay()
                }) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.previousState = strongSelf.state
                }
                .set(timingMode: animation.timing)
                .set(name: id)
            Tween.shared.add(period: period)
        }
        
        internal func set(state: State) {
            guard allowedState.contains(state) else { return }
            self.state = state
        }
    }
}

//MARK: - Touches

extension Component.View.Button {
    
    @objc private func touch(sender: TouchDownGestureRecognizer) {
        guard state != .disabled && state != .selected else { return }
        switch sender.state {
        case .began:
            guard allowedState.contains(.highlighted) else { return }
            state = .highlighted
            delegate?.touchDown(sender: self)
        case .ended:
            guard allowedState.contains(.normal) else { return }
            state = .normal
            let location = sender.location(in: self)
            guard bounds.contains(location) == true else {
                touchUpOutside()
                return
            }
            touchUpInside()
        default:
            break
        }
    }
    
    private func touchUpInside() {
        delegate?.touchUpInside(sender: self)
    }
    
    private func touchUpOutside() {
        delegate?.touchUpOutside(sender: self)
    }
}

//MARK: - Public methods

extension Component.View.Button {
    
    public func setBackgroundColor(_ color: UIColor, for state: State) {
        skin.backgroundColors[state] = (top: color, bottom: color)
        if state == .normal {
            skin.backgroundColors[.highlighted] = skin.backgroundColors[.highlighted] ?? (top: color, bottom: color)
            skin.backgroundColors[.disabled] = skin.backgroundColors[.disabled] ?? (top: color, bottom: color)
            skin.backgroundColors[.selected] = skin.backgroundColors[.selected] ?? (top: color, bottom: color)
        }
    }
    
    public func backgroundColor(for state: State) -> UIColor? {
        return skin.backgroundColors[state]??.top
    }
    
    public func setBackgroundGradientColors(_ colors: GradientVerticalColorPair, for state: State) {
        skin.backgroundColors[state] = colors
        if state == .normal {
            skin.backgroundColors[.highlighted] = skin.backgroundColors[.highlighted] ?? colors
            skin.backgroundColors[.disabled] = skin.backgroundColors[.disabled] ?? colors
            skin.backgroundColors[.selected] = skin.backgroundColors[.selected] ?? colors
        }
    }
    
    public func backgroundGradientColors(for state: State) -> GradientVerticalColorPair? {
        return skin.backgroundColors[state] ?? nil
    }
    
    public func setTitle(_ title: String?, for state: State) {
        if skin.titleAttributes[state] == nil {
            skin.titleAttributes[state] = (title: title, color: nil, font: nil)
        } else {
            skin.titleAttributes[state]?.title = title
        }
        if state == .normal {
            if skin.titleAttributes[.highlighted] == nil {
                skin.titleAttributes[.highlighted] = (title: title, color: nil, font: nil)
            }
            if skin.titleAttributes[.disabled] == nil {
                skin.titleAttributes[.disabled] = (title: title, color: nil, font: nil)
            }
            if skin.titleAttributes[.selected] == nil {
                skin.titleAttributes[.selected] = (title: title, color: nil, font: nil)
            }
        }
    }
    
    public func title(for state: State) -> String? {
        return skin.titleAttributes[state]?.title ?? skin.titleAttributes[.normal]?.title
    }
    
    public func setImage(_ image: UIImage?, tintColor: UIColor? = nil, for state: State) {
        skin.images[state] = (image, tintColor)
        if state == .normal {
            skin.images[.highlighted] = (skin.images[.highlighted]?.image ?? image, skin.images[.highlighted]?.tintColor ?? tintColor)
            skin.images[.disabled] = (skin.images[.disabled]?.image ?? image, skin.images[.disabled]?.tintColor ?? tintColor)
            skin.images[.selected] = (skin.images[.selected]?.image ?? image, skin.images[.selected]?.tintColor ?? tintColor)
        }
    }
    
    public func image(for state: State) -> UIImage? {
        return skin.images[state]?.image ?? skin.images[.normal]?.image
    }
    
    public func setTitleColor(_ color: UIColor, for state: State) {
        skin.titleAttributes[state]?.color = color
        if state == .normal {
            skin.titleAttributes[.highlighted]?.color = skin.titleAttributes[.highlighted]?.color ?? color
            skin.titleAttributes[.disabled]?.color = skin.titleAttributes[.disabled]?.color ?? color
            skin.titleAttributes[.selected]?.color = skin.titleAttributes[.selected]?.color ?? color
        }
    }
    
    public func titleColor(for state: State) -> UIColor? {
        return skin.titleAttributes[state]?.color ?? skin.titleAttributes[.normal]?.color
    }
    
    public func setTitleFont(_ font: UIFont, for state: State) {
        skin.titleAttributes[state]?.font = font
        if state == .normal {
            skin.titleAttributes[.highlighted]?.font = skin.titleAttributes[.highlighted]?.font ?? font
            skin.titleAttributes[.disabled]?.font = skin.titleAttributes[.disabled]?.font ?? font
            skin.titleAttributes[.selected]?.font = skin.titleAttributes[.selected]?.font ?? font
        }
    }
    
    public func titleFont(for state: State) -> UIFont? {
        return skin.titleAttributes[state]?.font ?? skin.titleAttributes[.normal]?.font
    }
}

extension Component.View.Button {
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard rect.width != 0 else { return }
        
        if previousBounds != rect {
            previousBounds = rect
            skin.frameDidChange(rect: rect)
        }
        
        UIColor.clear.setFill()
        UIRectFill(rect)
        
        skin.draw(rect: rect, stateTransition: (from: previousState, to: state), stateProgress: stateProgress)
    }
}

