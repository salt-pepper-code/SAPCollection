//
//  Example.TabBar.AdvanceViewController.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 15/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit
import Cartography
import SAPCollection

extension Example.TabBar {
    
    class AdvanceViewController: UIViewController, Menuable {
        
        static let title = "Advance"
        
        let tabBar: Component.View.TabBar = {
            let margins = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
            let skin = Component.Skin.TabBar.Advance(options: Component.Skin.TabBar.Advance.Options(margins: margins))
            return Component.View.TabBar(skin: skin, spacing: 0, margins: margins, animation: (0.4, .cubicInOut))
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            title = AdvanceViewController.title
            setup()
            
            let items = [Component.View.TabBarItem(skin: Component.Skin.TabBarItem.Advance(options: .default), animation: tabBar.animation),
                         Component.View.TabBarItem(skin: Component.Skin.TabBarItem.Advance(options: .default), animation: tabBar.animation),
                         Component.View.TabBarItem(skin: Component.Skin.TabBarItem.Advance(options: .default), animation: tabBar.animation),
                         Component.View.TabBarItem(skin: Component.Skin.TabBarItem.Advance(options: .default), animation: tabBar.animation),
                         Component.View.TabBarItem(skin: Component.Skin.TabBarItem.Advance(options: .default), animation: tabBar.animation)]
            
            items.enumerated().forEach { index, item in
                item.allowedState = [.normal, .selected]
                switch index {
                case 0: item.setImage(Asset.window.image, tintColor: UIColor(hex: 0x959595), for: .normal)
                case 1: item.setImage(Asset.thumbnails.image, tintColor: UIColor(hex: 0x959595), for: .normal)
                case 2: item.setImage(Asset.retweet.image, tintColor: UIColor(hex: 0x959595), for: .normal)
                case 3: item.setImage(Asset.chat.image, tintColor: UIColor(hex: 0x959595), for: .normal)
                case 4: item.setImage(Asset.more.image, tintColor: UIColor(hex: 0x959595), for: .normal)
                default:
                    break
                }
            }
            
            tabBar.set(items: items, animated: false)
        }
    }
}

extension Example.TabBar.AdvanceViewController: Subviewable {
    
    func setupSubviews() {
        tabBar.delegate = self
    }
    
    func setupStyles() {
        view.backgroundColor = .white
    }
    
    func setupHierarchy() {
        view.addSubview(tabBar)
    }
    
    func setupAutoLayout() {
        constrain(tabBar, self.view) { tabBar, view in
            tabBar.centerX == view.centerX
            tabBar.height == self.tabBar.skin.preferedSize().height
            tabBar.width == self.tabBar.skin.preferedSize().width
            tabBar.bottom == view.safeAreaLayoutGuide.bottom - 8
        }
    }
}

extension Example.TabBar.AdvanceViewController: Component.View.TabBar.Delegate {
    
    func tabBar(_ tabBar: Component.View.TabBar, didSelect item: Component.View.TabBarItem) {
        
    }
}
