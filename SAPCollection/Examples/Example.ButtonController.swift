//
//  Example.ButtonViewController.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 16/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit
import Cartography
import SAPCollection

extension Example {
    
    class ButtonViewController: UIViewController, Menuable {
    
        static let title = "Buttons"
        
        let buttonSimple: Component.View.Button = {
            let skin = Component.Skin.Button.Simple(options: .default)
            let button = Component.View.Button(skin: skin)
            button.name = "Button simple default"
            button.setTitle("Button", for: .normal)
            return button
        }()
        
        let buttonLeftImageSimple: Component.View.Button = {
            let skin = Component.Skin.Button.Simple(options: .default)
            let button = Component.View.Button(skin: skin)
            button.name = "Button simple with left image"
            button.setTitle("Button", for: .normal)
            button.setImage(Asset.download.image, for: .normal)
            return button
        }()
        
        let buttonRightImageSimple: Component.View.Button = {
            let skin = Component.Skin.Button.Simple(options: .default)
            skin.imageSide = .right
            let button = Component.View.Button(skin: skin)
            button.name = "right image"
            button.setTitle("Button", for: .normal)
            button.setImage(Asset.download.image, for: .normal)
            return button
        }()
        
        let buttonImageSimple: Component.View.Button = {
            let skin = Component.Skin.Button.Simple(options: .default)
            let button = Component.View.Button(skin: skin)
            button.name = "image"
            button.setImage(Asset.download.image, for: .normal)
            return button
        }()
        
        let buttonSimpleGradient: Component.View.Button = {
            let skin = Component.Skin.Button.Simple(options: .default)
            skin.options.border = nil
            let button = Component.View.Button(skin: skin)
            button.name = "Button simple default with gradient"
            button.setTitle("Button", for: .normal)
            button.setBackgroundGradientColors((top: UIColor(hex: 0xefefef), bottom: UIColor(hex: 0xbababa)), for: .normal)
            button.setBackgroundGradientColors((top: UIColor(hex: 0xcfe9f2), bottom: UIColor(hex: 0x81aab0)), for: .highlighted)
            button.setBackgroundGradientColors((top: UIColor(hex: 0xdddddd), bottom: UIColor(hex: 0xababab)), for: .disabled)
            return button
        }()
        
        let buttonAdvance: Component.View.Button = {
            let skin = Component.Skin.Button.Advance(options: .default)
            let button = Component.View.Button(skin: skin)
            button.name = "Button advance default"
            button.setTitle("Normal", for: .normal)
            button.setTitle("Pressed", for: .highlighted)
            return button
        }()
        
        let buttonAdvanceSelected: Component.View.Button = {
            let skin = Component.Skin.Button.Advance(options: .default)
            let button = Component.View.Button(skin: skin)
            button.name = "Selected"
            button.setTitle("Selected", for: .selected)
            button.isSelected = true
            return button
        }()
        
        let buttonAdvanceDisabled: Component.View.Button = {
            let skin = Component.Skin.Button.Advance(options: .default)
            let button = Component.View.Button(skin: skin)
            button.name = "Button advance default enabled after 3 sec"
            button.setTitle("Normal", for: .normal)
            button.setTitle("Pressed", for: .highlighted)
            button.setTitle("Disabled", for: .disabled)
            button.isEnabled = false
            return button
        }()
        
        var views = [[Component.View.Button]]()
        let tableView = UITableView()
        
        required init() {
            super.init(nibName: nil, bundle: nil)
            setup()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            title = ButtonViewController.title
            view.backgroundColor = .white
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(3000)) { [weak self] in
                self?.buttonAdvanceDisabled.isEnabled = true
            }
        }
    }
}

extension Example.ButtonViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return views.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? Example.Cell {
            let views = self.views[indexPath.row]
            views.forEach { view in
                view.delegate = self
                cell.set(contentSubview: view)
            }
            return cell
        }
        return UITableViewCell()
    }
}

extension Example.ButtonViewController: Subviewable {
    
    func setupSubviews() {
        views = [[buttonSimple],
                 [buttonLeftImageSimple, buttonRightImageSimple, buttonImageSimple],
                 [buttonSimpleGradient],
                 [buttonAdvance, buttonAdvanceSelected],
                 [buttonAdvanceDisabled]]
        views.flatMap { $0 }.forEach {
            $0.delegate = self
        }
        tableView.register(Example.Cell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
    }
    
    func setupStyles() {

    }
    
    func setupHierarchy() {
        view.addSubview(tableView)
    }
    
    func setupAutoLayout() {
        constrain(tableView, self.view) { tableView, view in
            tableView.top == view.safeAreaLayoutGuide.top + 8
            tableView.leading == view.leading + 16
            tableView.trailing == view.trailing - 16
            tableView.bottom == view.safeAreaLayoutGuide.bottom
        }
        views.flatMap { $0 }.forEach {
             $0.autoresizing = true
        }
    }
}

extension Example.ButtonViewController: Component.View.Button.Delegate {
    
    func touchDown(sender: Component.View.Button) {
        
    }
    
    func touchUpInside(sender: Component.View.Button) {
        if sender == buttonAdvanceDisabled {
            buttonAdvanceDisabled.isEnabled = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(3000)) { [weak self] in
                self?.buttonAdvanceDisabled.isEnabled = true
            }
        }
    }
    
    func touchUpOutside(sender: Component.View.Button) {
        
    }
    
    func didSelect(sender: Component.View.Button) {
        
    }
}
