//
//  Component.View.PageControl.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 15/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit

public protocol ComponentPageControlSkinable: Skinable {
    func draw(rect: CGRect, currentPage: CGFloat, numberOfPages: Int)
}

public protocol ComponentPageControlDelegate: class {
    func pageControl(didSelect page: Int)
    func pageControl(didPan page: CGFloat)
    func pageControl(panEnded page: Int)
}

extension Component.View {
    
    public class PageControl: UIView, Nameable {
        
        public typealias Delegate = ComponentPageControlDelegate

        public weak var delegate: Delegate?
        
        private(set) public var id: String = UUID().uuidString
        public var name = "Component.View.PageControl"
        
        private var previousBounds: CGRect = .zero
        private var space: CGFloat = 0
        public let skin: ComponentPageControlSkinable
        
        private(set) public var numberOfPages: Int {
            didSet {
                refresh()
            }
        }
        private(set) public var currentPage: CGFloat = 0 {
            didSet {
                setNeedsDisplay()
            }
        }
        
        public required init(numberOfPages: Int, skin: ComponentPageControlSkinable) {
            self.numberOfPages = numberOfPages
            self.skin = skin
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
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan))
            panGesture.maximumNumberOfTouches = 1
            panGesture.minimumNumberOfTouches = 1
            addGestureRecognizer(panGesture)
            
            backgroundColor = .clear
            refresh()
        }
    }
}

//MARK: - Gestures

extension Component.View.PageControl {
    
    @objc private func didTap(sender: UITapGestureRecognizer) {
        let location = sender.location(in: self)
        let position = (roundf(location.x / space) - 1).clamped(to: 0...CGFloat(numberOfPages-1))
        delegate?.pageControl(didSelect: Int(position))
    }
    
    @objc private func didPan(sender: UIPanGestureRecognizer) {
        let location = sender.location(in: self)
        if sender.state == .ended {
            let position = (roundf(location.x / space) - 1).clamped(to: 0...CGFloat(numberOfPages-1))
            delegate?.pageControl(panEnded: Int(position))
        } else {
            let position = location.x / space
            set(currentPage: position - 1)
            delegate?.pageControl(didPan: currentPage)
        }
    }
}

//MARK: - Public methods

extension Component.View.PageControl {
    
    public func refresh() {
        setNeedsDisplay()
    }
    
    public func set(numberOfPages: Int) {
        self.numberOfPages = numberOfPages.clamped(to: 0...Int.max)
        self.currentPage = currentPage.clamped(to: 0...CGFloat(numberOfPages-1))
    }
    
    public func set(currentPage: CGFloat) {
        self.currentPage = currentPage.clamped(to: 0...CGFloat(numberOfPages-1))
    }
}

//MARK: - Drawing

extension Component.View.PageControl {
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard rect.width != 0 else { return }
        
        if previousBounds != rect {
            previousBounds = rect
            skin.frameDidChange(rect: rect)
        }
        
        (backgroundColor ?? .clear).setFill()
        UIRectFill(rect)
        
        skin.draw(rect: rect, currentPage: currentPage, numberOfPages: numberOfPages)
    }
}
