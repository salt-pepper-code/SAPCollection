//
//  SplashScreenViewController.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 04/04/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit
import MKTween
import Macaw
import SAPCollection

protocol SplashScreenDelegate: class {
    func animationFinished()
}

class SplashScreenViewController: UIViewController, SplashScreenDelegate {

    override func loadView() {
        self.view = SplashScreenView(delegate: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: 0xF6F6F6)
    }
    
    func animationFinished() {
        let navigation = UINavigationController(rootViewController: Example.Menu())
        addChild(navigation)
        view.addSubview(navigation.view)
        navigation.didMove(toParent: self)
    }
}

class SplashScreenView: MacawView {

    weak var delegate: SplashScreenDelegate?
    
    var sShape: Node? {
        return node.nodeBy(tag: "S")
    }
    var sShapeForms: Node? {
        return node.nodeBy(tag: "Sforms")
    }
    var pShape: Node? {
        return node.nodeBy(tag: "P")
    }
    var pShapeForms: Node? {
        return node.nodeBy(tag: "Pforms")
    }
    var sapcName: Node? {
        return node.nodeBy(tag: "SAPC")
    }
    
    convenience init(delegate: SplashScreenDelegate) {
        let group = Group(contents: [Group(contents: [try! SVGParser.parse(resource: "S")], tag: ["S"]),
                                     Group(contents: [try! SVGParser.parse(resource: "P")], tag: ["P"]),
                                     Group(contents: [try! SVGParser.parse(resource: "Sforms")], tag: ["Sforms"]),
                                     Group(contents: [try! SVGParser.parse(resource: "Pforms")], tag: ["Pforms"]),
                                     Group(contents: [try! SVGParser.parse(resource: "SAPC")], tag: ["SAPC"])
            ])
        self.init(node: group, frame: .zero)
        self.delegate = delegate
        start()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let scale: Double = 2
        if let node = sShape, let bounds = node.bounds {
            node.place = node.place
                .move(dx: Double(frame.width.half) - (bounds.w * scale), dy: Double(frame.height.half) - ((bounds.h * scale) / 2))
                .scale(sx: scale, sy: scale)
        }
        if let node = sShapeForms, let bounds = node.bounds {
            node.place = node.place
                .move(dx: Double(frame.width.half) - (bounds.w * scale), dy: Double(frame.height.half) - ((bounds.h * scale) / 2))
                .scale(sx: scale, sy: scale)
        }
        if let node = pShape, let bounds = node.bounds {
            node.place = node.place
                .move(dx: Double(frame.width.half), dy: Double(frame.height.half) - ((bounds.h * scale) / 2))
                .scale(sx: scale, sy: scale)
        }
        if let node = pShapeForms, let bounds = node.bounds {
            node.place = node.place
                .move(dx: Double(frame.width.half), dy: Double(frame.height.half) - ((bounds.h * scale) / 2))
                .scale(sx: scale, sy: scale)
        }
        if let node = sapcName, let bounds = node.bounds, let otherBounds = pShapeForms?.bounds?.applying(pShapeForms!.place) {
            node.place = node.place
                .move(dx: Double(frame.width.half) - ((bounds.w * scale) / 2), dy: otherBounds.y + otherBounds.h + 20)
                .scale(sx: scale, sy: scale)
        }
    }
    
    func start() {
        guard let sShape = sShape else { return }
        sShape.opacity = 0
        guard let sShapeForms = (sShapeForms as? Macaw.Group) else { return }
        sShapeForms.shapes().forEach { $0.opacity = 0 }
        guard let pShape = pShape else { return }
        pShape.opacity = 0
        guard let pShapeForms = (pShapeForms as? Macaw.Group) else { return }
        pShapeForms.shapes().forEach { $0.opacity = 0 }
        guard let sapcName = sapcName else { return }
        sapcName.opacity = 0

        let period = Period(start: Double(0), end: 1, duration: 3, delay: 1)
            .set(update: { [weak self] period in
                self?.sShape?.opacity = period.progress
                self?.pShape?.opacity = period.progress
            })
            .set(timingMode: .linear)
        
        let periods = (sShapeForms.shapes() + pShapeForms.shapes())
            .enumerated()
            .map { index, shape -> BasePeriod in
                Period(start: Double(0), end: 1, duration: 1, delay: TimeInterval(index)/2).set(update: { period in
                    shape.opacity = period.progress
                }).set(timingMode: .linear)
        }
        
        let periodText = Period(start: Double(0), end: 1, duration: 1)
            .set(update: { [weak self] period in
                self?.sapcName?.opacity = period.progress
            })
            .set(timingMode: .linear)
        
        let group = Group(periods: periods)
        let sequence = Sequence(periods: [period, group, periodText]).set(completion: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.animationFinished()
        })
        
        Tween.shared.add(period: sequence)
    }
}

extension Node {
    
    func transformedBounds() -> Rect? {
        if let bounds = self.bounds {
            return Rect(x: bounds.x, y: bounds.y, w: bounds.w * place.m11, h: bounds.h * place.m22)
        }
        return nil
    }
}

extension Macaw.Group {
    
    func shapes() -> [Shape] {
        let shapes = contents.filter { $0 is Shape || $0 is Macaw.Group }.map { content -> [Shape] in
            if let shape = content as? Shape {
                return [shape]
            }
            return (content as! Macaw.Group).shapes()
        }
        return shapes.flatMap { $0 }
    }
}

extension Rect {
    
    public static func * (lhs: Rect, scalar: Double) -> Rect {
        return Rect(x: lhs.x, y: lhs.y, w: lhs.w * scalar, h: lhs.h * scalar)
    }
}
