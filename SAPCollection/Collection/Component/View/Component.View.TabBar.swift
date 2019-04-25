//
//  Component.View.TabBar.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 28/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit
import Cartography
import MKTween

public protocol ComponentTabBarSkinable: Skinable {
    func draw(rect: CGRect, indexCount: Int, fromIndex: Int, toIndex: Int, indexProgress: CGFloat)
}

public protocol ComponentTabBarDelegate: class {
    func tabBar(_ tabBar: Component.View.TabBar, didSelect item: Component.View.TabBarItem)
}

extension Component.View {
    
    public class TabBar: UIView, Nameable {
        
        public typealias Delegate = ComponentTabBarDelegate
        
        public weak var delegate: Delegate?
        private(set) public var id: String = UUID().uuidString
        public var name = "Component.View.TabBar"
        public var items: [TabBarItem]?
        public var selectedItem: TabBarItem?
        
        private var previousBounds: CGRect = .zero
        private let stackView = UIStackView()
        private var progress: CGFloat = 0
        
        private var previousIndex: Int = 0
        private var currentIndex: Int = 0
        
        public let spacing: CGFloat
        public let margins: UIEdgeInsets
        
        public let animation: (duration: TimeInterval, timing: Timing)?
        public var skin: ComponentTabBarSkinable {
            didSet {
                setNeedsDisplay()
            }
        }
        
        public required init(skin: ComponentTabBarSkinable, spacing: CGFloat = 0, margins: UIEdgeInsets = .zero, animation: (duration: TimeInterval, timing: Timing)? = nil) {
            self.skin = skin
            self.animation = animation
            self.spacing = spacing
            self.margins = margins
            super.init(frame: .zero)
            setup()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public func set(items: [TabBarItem]?, animated: Bool) {
            self.items = items
            clearStack()
            buildItems(animated: animated)
        }
        
        private func clearStack() {
            let arrangedSubviews = stackView.arrangedSubviews
            arrangedSubviews.forEach {
                stackView.removeArrangedSubview($0)
            }
        }
        
        private func buildItems(animated: Bool) {
            items?.forEach {
                $0.autoresizing = false
                $0.delegate = self
                stackView.addArrangedSubview($0)
            }
            setNeedsDisplay()
        }
        
        public func select(index: Int) {
            self.previousIndex = currentIndex
            self.currentIndex = index
            guard let animation = animation else {
                progress = 1
                setNeedsDisplay()
                return
            }
            progress = progress != CGFloat(currentIndex) ? CGFloat(previousIndex) : progress
            Tween.shared.removePeriod(by: "\(id)")
            let period = Period(start: progress, end: CGFloat(currentIndex), duration: animation.duration, delay: 0).set(update: { [weak self] period in
                self?.progress = period.progress
                self?.setNeedsDisplay()
            }) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.previousIndex = strongSelf.currentIndex
            }.set(timingMode: animation.timing).set(name: id)
            Tween.shared.add(period: period)
        }
    }
}

extension Component.View.TabBar {
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard rect.width != 0 else { return }
        
        if previousBounds != rect {
            previousBounds = rect
            skin.frameDidChange(rect: rect)
        }
        
        UIColor.clear.setFill()
        UIRectFill(rect)
        
        guard let items = items else { return }
        
        skin.draw(rect: rect, indexCount: items.count, fromIndex: previousIndex, toIndex: currentIndex, indexProgress: progress)
        
        var stateProgress: [CGFloat] = (0..<items.count).map { _ -> CGFloat in 1 }
        let states = (0..<items.count).map { int -> ButtonTransitionStates in
            let index = CGFloat(int)
            let distance = abs(index - progress)
            stateProgress[int] = 1
            if 0...1 ~= distance {
                switch index {
                case CGFloat(currentIndex):
                    if currentIndex - previousIndex == 0 {
                        return (.selected, .selected)
                    } else {
                        stateProgress[int] = 1 - distance
                        return (.normal, .selected)
                    }
                case CGFloat(previousIndex):
                    if currentIndex - previousIndex == 0 {
                        return (.normal, .normal)
                    } else {
                        stateProgress[int] = distance
                        return (.selected, .normal)
                    }
                default:
                    break
                }
            }
            return (.normal, .normal)
        }

        items.enumerated().forEach { index, item in
            item.position = Component.View.TabBarItem.Position(index: index, count: items.count)
            item.set(state: states[index].to)
        }
    }
}

extension Component.View.TabBar: ComponentTabBarItemDelegate {
    
    public func touchDown(sender: Component.View.Button) {
        
    }
    
    public func touchUpInside(sender: Component.View.Button) {
        if let index = items?.firstIndex(where: { item -> Bool in
            item == sender
        }) {
            select(index: index)
        }
    }
    
    public func touchUpOutside(sender: Component.View.Button) {
        
    }
    
    public func didSelect(sender: Component.View.Button) {
        
    }
}

extension Component.View.TabBar: Subviewable {
    
    func setupSubviews() {
        backgroundColor = .clear
        stackView.axis = .horizontal
        stackView.spacing = spacing
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
    }
    
    func setupStyles() {

    }
    
    func setupHierarchy() {
        addSubview(stackView)
    }
    
    func setupAutoLayout() {
        constrain(stackView, self) { stack, view in
            stack.top == view.top + margins.top
            stack.bottom == view.bottom - margins.bottom
            stack.leading == view.leading + margins.left
            stack.trailing == view.trailing - margins.right
        }
    }
}
