//
//  Example.SwitchViewController.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 16/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit
import Cartography
import SAPCollection

extension Example {
    
    class SwitchViewController: UIViewController, Menuable {
    
        static let title = "Switches"
        
        let switchSimple: Component.View.Switch = {
            let skin = Component.Skin.Switch.Simple(options: .default)
            let view = Component.View.Switch(skin: skin)
            view.name = "Switch simple default"
            return view
        }()
        let switchSimpleInner: Component.View.Switch = {
            let skin = Component.Skin.Switch.Inner(options: .default)
            let view =  Component.View.Switch(skin: skin)
            view.name = "Switch inner default"
            return view
        }()
        let switchDownload: Component.View.Switch = {
            let skin = Component.Skin.Switch.Activate(image: Asset.download.image, options: .default)
            let view =  Component.View.Switch(skin: skin, animation: (0.9, .expoInOut))
            view.name = "Switch Advance activate default"
            return view
        }()
        let switchOnOff: Component.View.Switch = {
            let skin = Component.Skin.Switch.OnOff(options: .default)
            let view =  Component.View.Switch(skin: skin)
            view.name = "Switch Advance OnOff default"
            return view
        }()
        
        var views = [Component.View.Switch]()
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
            title = SwitchViewController.title
            view.backgroundColor = .white
        }
    }
}

extension Example.SwitchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return views.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? Example.Cell {
            let view = views[indexPath.row]
            view.delegate = self
            cell.set(contentSubview: view)
            return cell
        }
        return UITableViewCell()
    }
}

extension Example.SwitchViewController: Subviewable {
    
    func setupSubviews() {
        views = [switchSimple, switchSimpleInner, switchDownload, switchOnOff]

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
        views.forEach {
            let size = $0.skin.preferedSize()
            constrain($0, self.view) { subview, view in
                subview.width == size.width
                subview.height == size.height
            }
        }
    }
}

extension Example.SwitchViewController: Component.View.Switch.Delegate {
    
    func stateChanged(switch: Component.View.Switch, on: Bool) {
        
    }
}
