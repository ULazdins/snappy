//
//  DetailsViewController.swift
//  Snapp
//
//  Created by Uģis Lazdiņš on 09/07/2019.
//  Copyright © 2019 Uģis Lazdiņš. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    var screen: DetailsStackScreen!
    var mainTitle: String!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = mainTitle
    }
}
