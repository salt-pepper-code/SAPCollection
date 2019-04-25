//
//  Example.PageControlViewController.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 15/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit
import Cartography
import SAPCollection

extension Example {
    
    class PageControlViewController: UIViewController, Menuable {
        
        static let title = "Page Control"
        
        static let numberOfPages: Int = 5
        let numberOfPages = PageControlViewController.numberOfPages
        
        let pageControl: Component.View.PageControl = {
            let skin = Component.Skin.PageControl.Scale(options: .default)
            return Component.View.PageControl(numberOfPages: numberOfPages, skin: skin)
        }()

        private var pageIndex: Int = 0
        
        private static let detailsLayout: UICollectionViewFlowLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            layout.minimumInteritemSpacing = 16
            layout.minimumLineSpacing = 16
            return layout
        }()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: detailsLayout)
        
        override func viewDidLoad() {
            super.viewDidLoad()
            title = PageControlViewController.title
            view.backgroundColor = UIColor(hex: 0xD8416F)
            setup()
        }
    }
}

extension Example.PageControlViewController: Subviewable {
    
    func setupSubviews() {
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = false
        
        pageControl.delegate = self
    }
    
    func setupStyles() {
        collectionView.backgroundColor = .clear
    }
    
    func setupHierarchy() {
        view.addSubview(collectionView)
        view.addSubview(pageControl)
    }
    
    func setupAutoLayout() {
        constrain(pageControl, collectionView, self.view) { pager, collection, view in
            collection.top == view.safeAreaLayoutGuide.top + 8
            collection.leading == view.leading
            collection.trailing == view.trailing
            
            pager.top == collection.bottom
            pager.centerX == view.centerX
            pager.height == pageControl.skin.preferedSize().height
            pager.width == pageControl.skin.preferedSize().width
            pager.bottom == view.bottom
        }
    }
}

extension Example.PageControlViewController: Component.View.PageControl.Delegate {
    
    func pageControl(didSelect page: Int) {
        collectionView.setContentOffset(CGPoint(x: collectionView.frame.width * page.cgfloat, y: 0), animated: true)
    }
    
    func pageControl(didPan page: CGFloat) {
        collectionView.setContentOffset(CGPoint(x: collectionView.frame.width * page, y: 0), animated: false)
    }
    
    func pageControl(panEnded page: Int) {
        collectionView.setContentOffset(CGPoint(x: collectionView.frame.width * page.cgfloat, y: 0), animated: true)
    }
}

extension Example.PageControlViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfPages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.contentView.backgroundColor = .white
        cell.contentView.layer.cornerRadius = 20
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 16, height: collectionView.frame.height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.frame != .zero else { return }
        let progress = (scrollView.contentOffset.x / scrollView.frame.width).clamped(to: 0...numberOfPages.cgfloat-1)
        pageControl.set(currentPage: progress)
        let index = Int(progress)
        if index != pageIndex {
            pageIndex = index
        }
    }
}
