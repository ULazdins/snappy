//
//  MainMenu.swift
//  Snapp
//
//  Created by Uģis Lazdiņš on 09/07/2019.
//  Copyright © 2019 Uģis Lazdiņš. All rights reserved.
//

import UIKit

class MainMenu: UITabBarController {
    var structure: Structure! = nil
    
    override func viewWillAppear(_ animated: Bool) {
        let graphQlClient = GraphQlClient(graphQlUrl: structure.graphQlUrl, bearerToken: structure.graphQlAuthToken)
        
        self.viewControllers = structure.menu.items.compactMap({ (menuItem) -> UIViewController? in
            let screen = structure.screens.first {$0.id == menuItem.screenId }
            
            switch (screen) {
            case let screen as TableScreen:
                let vc = MainTableViewController()
                vc.screen = screen
                vc.structure = structure
                vc.graphQlClient = graphQlClient
                vc.tabBarItem = UITabBarItem(title: menuItem.title, image: menuItem.iconName.map(UIImage.init), tag: 0)
                
                let nav = UINavigationController(rootViewController: vc)
                
                return nav
            case let screen as DetailsStackScreen:
                let vc = DetailsViewController()
                vc.screen = screen
                vc.tabBarItem = UITabBarItem(title: menuItem.title, image: menuItem.iconName.map(UIImage.init), tag: 0)
                
                let nav = UINavigationController(rootViewController: vc)
                
                return nav
            default:
                abort()
            }
        })
        
        self.title = viewControllers?.first?.tabBarItem.title
        
        self.delegate = self
        
        super.viewWillAppear(animated)
    }
}

extension MainMenu: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.title = viewController.tabBarItem.title
    }
}
