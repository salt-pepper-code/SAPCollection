//
//  Component.View.TabBarItem.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 29/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit
import MKTween

typealias ComponentTabBarItemDelegate = ComponentButtonDelegate

public protocol ComponentTabBarItemSkinable: ComponentButtonSkinable {
    func draw(rect: CGRect, stateTransition: ButtonTransitionStates, stateProgress: CGFloat, position: Component.View.TabBarItem.Position)
}

extension Component.View {
    
    public class TabBarItem: Component.View.Button {
        
        public enum Position {
            case first
            case intern
            case last
        }
        
        public var badgeValue: Int?
        public var badgeColor: UIColor?
        public var position: Position = .intern
    }
}

extension Component.View.TabBarItem {
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let skin = skin as? ComponentTabBarItemSkinable {
            skin.draw(rect: rect, stateTransition: (from: previousState, to: state), stateProgress: stateProgress, position: position)
        }
    }
}

extension Component.View.TabBarItem.Position {
    
    init(index: Int, count: Int) {
        if index == 0 {
            self = .first
        } else if index == count - 1 {
            self = .last
        } else {
            self = .intern
        }
    }
}
