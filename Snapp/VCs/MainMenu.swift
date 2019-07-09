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
        
        self.viewControllers = structure.menu.items.compactMap({ (menuItem) -> UIViewController? in
            let screen = structure.screens.first {$0.id == menuItem.screenId }
            
            switch (screen) {
            case let screen as TableScreen:
                let vc = MainTableViewController()
                vc.screen = screen
                vc.tabBarItem = UITabBarItem(title: menuItem.title, image: nil, tag: 0)
                return vc
            case let screen as DetailsStackScreen:
                let vc = DetailsViewController()
                vc.screen = screen
                vc.tabBarItem = UITabBarItem(title: menuItem.title, image: nil, tag: 0)
                return vc
            default:
                abort()
            }
        })
        
        super.viewWillAppear(animated)
    }
}
