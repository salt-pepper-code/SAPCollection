//
//  AppDelegate.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 15/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if !UserDefaults.standard.bool(forKey: "first-time") {
            UserDefaults.standard.set(true, forKey: "first-time")
            window?.rootViewController = SplashScreenViewController()
        } else {
            window?.rootViewController = UINavigationController(rootViewController: Example.Menu())
        }
        window?.makeKeyAndVisible()
        return true
    }
}
