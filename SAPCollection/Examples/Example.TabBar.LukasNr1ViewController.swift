//
//  Example.TabBar.LukasNr1ViewController.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 15/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit
import Cartography
import SAPCollection

extension Example.TabBar {
    
    class LukasNr1ViewController: UIViewController, Menuable {
        
        static let title = "Lukas Nr1"
        
        let tabBar: Component.View.TabBar = {
            let skin = Component.Skin.TabBar.LukasNr1()
            return Component.View.TabBar(skin: skin, animation: (0.4, .cubicInOut))
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            title = LukasNr1ViewController.title
            setup()
            
            let items = [Component.View.TabBarItem(skin: Component.Skin.TabBarItem.LukasNr1(), animation: tabBar.animation),
                         Component.View.TabBarItem(skin: Component.Skin.TabBarItem.LukasNr1(), animation: tabBar.animation),
                         Component.View.TabBarItem(skin: Component.Skin.TabBarItem.LukasNr1(), animation: tabBar.animation),
                         Component.View.TabBarItem(skin: Component.Skin.TabBarItem.LukasNr1(), animation: tabBar.animation),
                         Component.View.TabBarItem(skin: Component.Skin.TabBarItem.LukasNr1(), animation: tabBar.animation)]
            
            items.enumerated().forEach { index, item in
                item.allowedState = [.normal, .selected]
                item.setBackgroundColor(.white, for: .normal)
                switch index {
                case 0:
                    item.setImage(Asset.window.image, tintColor: UIColor(hex: 0xD3D2D4), for: .normal)
                    item.setImage(Asset.window.image, tintColor: UIColor(hex: 0x282828), for: .selected)
                case 1:
                    item.setImage(Asset.thumbnails.image, tintColor: UIColor(hex: 0xD3D2D4), for: .normal)
                    item.setImage(Asset.thumbnails.image, tintColor: UIColor(hex: 0x282828), for: .selected)
                case 2:
                    item.setImage(Asset.retweet.image, tintColor: UIColor(hex: 0xD3D2D4), for: .normal)
                    item.setImage(Asset.retweet.image, tintColor: UIColor(hex: 0x282828), for: .selected)
                case 3:
                    item.setImage(Asset.chat.image, tintColor: UIColor(hex: 0xD3D2D4), for: .normal)
                    item.setImage(Asset.chat.image, tintColor: UIColor(hex: 0x282828), for: .selected)
                case 4:
                    item.setImage(Asset.more.image, tintColor: UIColor(hex: 0xD3D2D4), for: .normal)
                    item.setImage(Asset.more.image, tintColor: UIColor(hex: 0x282828), for: .selected)
                default:
                    break
                }
            }
            
            tabBar.set(items: items, animated: false)
        }
    }
}

extension Example.TabBar.LukasNr1ViewController: Subviewable {
    
    func setupSubviews() {
        tabBar.delegate = self
    }
    
    func setupStyles() {
        view.backgroundColor = UIColor(hex: 0x5FD9E8)
    }
    
    func setupHierarchy() {
        view.addSubview(tabBar)
    }
    
    func setupAutoLayout() {
        constrain(tabBar, self.view) { tabBar, view in
            tabBar.leading == view.leading
            tabBar.trailing == view.trailing
            tabBar.height == self.tabBar.skin.preferedSize().height
            tabBar.bottom == view.safeAreaLayoutGuide.bottom
        }
    }
}

extension Example.TabBar.LukasNr1ViewController: Component.View.TabBar.Delegate {
    
    func tabBar(_ tabBar: Component.View.TabBar, didSelect item: Component.View.TabBarItem) {
        
    }
}
