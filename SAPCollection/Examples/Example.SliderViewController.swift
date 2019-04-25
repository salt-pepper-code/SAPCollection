//
//  Example.SliderViewController.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 18/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit
import Cartography
import SAPCollection

extension Example {
    
    class SliderViewController: UIViewController, Menuable {
        
        static let title = "Sliders"
        
        let horizontalSliderSimpleLeading: Component.View.Slider = {
            let options = Component.Skin.Slider.Simple.Options(direction: .horizontal, fillingMode: .leading)
            let skin = Component.Skin.Slider.Simple(options: options)
            let view = Component.View.Slider(skin: skin)
            view.name = "Slider simple horizontal leading"
            return view
        }()
        let horizontalSliderSimpleProgressive: Component.View.Slider = {
            let options = Component.Skin.Slider.Simple.Options(direction: .horizontal, fillingMode: .progressive)
            let skin = Component.Skin.Slider.Simple(options: options)
            let view = Component.View.Slider(skin: skin)
            view.name = "Slider simple horizontal progressive"
            return view
        }()
        let verticalSliderSimpleLeading: Component.View.Slider = {
            let options = Component.Skin.Slider.Simple.Options(direction: .vertical, fillingMode: .leading)
            let skin = Component.Skin.Slider.Simple(options: options)
            let view = Component.View.Slider(skin: skin)
            view.name = "Slider simple vertical leading"
            return view
        }()
        let sliderAdvance: Component.View.Slider = {
            let skin = Component.Skin.Slider.Advance(options: .default)
            let view = Component.View.Slider(skin: skin)
            view.name = "Slider Advance classic default"
            return view
        }()
        let sliderAdvanceSharp: Component.View.Slider = {
            let skin = Component.Skin.Slider.Advance(options: .sharp)
            let view = Component.View.Slider(skin: skin)
            view.name = "Slider Advance classic sharp"
            return view
        }()
        let sliderRangeAdvance: Component.View.SliderRange = {
            let skin = Component.Skin.SliderRange.Advance(options: .default)
            let view = Component.View.SliderRange(skin: skin)
            view.name = "Slider Range Advance classic default"
            return view
        }()
        let sliderRangeAdvanceSharp: Component.View.SliderRange = {
            let skin = Component.Skin.SliderRange.Advance(options: .sharp)
            let view = Component.View.SliderRange(skin: skin)
            view.name = "Slider Range Advance classic sharp"
            return view
        }()
        
        var sliders = [Component.View.Slider]()
        var sliderRangers = [Component.View.SliderRange]()
        let tableView = UITableView()
        
        var views: [UIView & Nameable] {
            return (sliders as [UIView & Nameable]) + (sliderRangers as [UIView & Nameable])
        }
        
        required init() {
            super.init(nibName: nil, bundle: nil)
            setup()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            title = SliderViewController.title
            view.backgroundColor = .white
        }
    }
}

extension Example.SliderViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return views.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? Example.Cell {
            let view = views[indexPath.row]
            if let view = view as? Component.View.Slider {
                view.set(minimumValue: 0, maximumValue: 100)
                view.animate(to: 50, delay: 1)
               view.delegate = self
            }
            if let view = view as? Component.View.SliderRange {
                view.set(minimumValue: 0, maximumValue: 1000)
                view.animate(to: (left: 150, right: 600), delay: 1)
                view.delegate = self
            }
            cell.set(contentSubview: view)
            return cell
        }
        return UITableViewCell()
    }
}

extension Example.SliderViewController: Subviewable {
    
    func setupSubviews() {
        sliders = [horizontalSliderSimpleLeading, horizontalSliderSimpleProgressive, verticalSliderSimpleLeading, sliderAdvance, sliderAdvanceSharp]
        sliderRangers = [sliderRangeAdvance, sliderRangeAdvanceSharp]
        
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
        sliders.forEach {
            let size = $0.skin.preferedSize()
            constrain($0) { subview in
                subview.width == size.width
                subview.height == size.height
            }
        }
        sliderRangers.forEach {
            let size = $0.skin.preferedSize()
            constrain($0) { subview in
                subview.width == size.width
                subview.height == size.height
            }
        }
    }
}

extension Example.SliderViewController: Component.View.Slider.Delegate {
    
    func valueChanged(slider: Component.View.Slider, value: CGFloat) {

    }
}

extension Example.SliderViewController: Component.View.SliderRange.Delegate {
    
    func valueChanged(slider: Component.View.SliderRange, values: SliderRangeValuePair) {
        
    }
}
