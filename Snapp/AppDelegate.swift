//
//  AppDelegate.swift
//  Snapp
//
//  Created by Uģis Lazdiņš on 09/07/2019.
//  Copyright © 2019 Uģis Lazdiņš. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private var structure: Structure!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        structure = Bundle.main.path(forResource: "structure", ofType: "json")
            .flatMap({ (path) -> URL? in
                return URL(fileURLWithPath: path)
            })
            .flatMap({ (url) -> Data? in
                return try! Data(contentsOf: url)
            })
            .flatMap { (data) -> Structure? in
                try! JSONDecoder().decode(Structure.self, from: data)
            }
        
        setupStyle(structure: structure)
        
        let initialViewController = MainMenu()
        initialViewController.structure = structure
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    private func setupStyle(structure: Structure) {
        let mainColor = UIColor(hex: structure.theme.primaryColor)
        let secondaryColor = UIColor(hex: structure.theme.secondaryColor)
        
//        application.delegate?.window??.tintColor = mainColor
        
        UINavigationBar.appearance().prefersLargeTitles = structure.theme.prefersLargeTitles
        
        UINavigationBar.appearance().barTintColor = secondaryColor
        UINavigationBar.appearance().tintColor = mainColor
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:mainColor]
        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:mainColor]
        
        //        UINavigationBar.appearance().setBackgroundImage(theme.navigationBackgroundImage, forBarMetrics: .Default)
        
        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "backArrow")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "backArrow")
        
        
        UITabBar.appearance().barTintColor = secondaryColor
        UITabBar.appearance().tintColor = mainColor
        //        UITabBar.appearance().backgroundImage = tabBarBackgroundImage
        
        let tabIndicator = UIImage(named: "tabBarSelectionIndicator")?.withRenderingMode(.alwaysTemplate)
        let tabResizableIndicator = tabIndicator?.resizableImage(
            withCapInsets: UIEdgeInsets(top: 0, left: 2.0, bottom: 0, right: 2.0))
        UITabBar.appearance().selectionIndicatorImage = tabResizableIndicator

    }
}

/*
 TODO:
 - vēl viens kartiņu stils
 - oauth login
 - pogas - sekot/nesekot
 - pieejamība
 - drawer
 - pagination of search results
 - bez-e example config
 */
