//
//  Example.Menu.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 21/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit
import Cartography
import SAPCollection

protocol Menuable {
    init()
    static var title: String { get }
}

enum Example {
    enum TabBar {}
}

extension Example {
    
    class Menu: UIViewController {
        
        let tableView = UITableView()
        let data: [(Menuable & UIViewController).Type] = [ButtonViewController.self,
                                                          SliderViewController.self,
                                                          SwitchViewController.self,
                                                          PageControlViewController.self,
                                                          TabBarsViewController.self]
        
        init() {
            super.init(nibName: nil, bundle: nil)
            setup()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            title = "Examples"
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
}

extension Example.Menu: Subviewable {
    
    func setupSubviews() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = 60
    }
    
    func setupStyles() {
        
    }
    
    func setupHierarchy() {
        view.addSubview(tableView)
    }
    
    func setupAutoLayout() {
        constrain(tableView, self.view) { tableView, view in
            tableView.edges == view.edges
        }
    }
}

extension Example.Menu: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row].title
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(data[indexPath.row].init(), animated: true)
    }
}
