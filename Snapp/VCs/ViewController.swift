//
//  ViewController.swift
//  Snapp
//
//  Created by Uģis Lazdiņš on 09/07/2019.
//  Copyright © 2019 Uģis Lazdiņš. All rights reserved.
//

import UIKit

class ViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let structure = Bundle.main.path(forResource: "structure", ofType: "json")
            .flatMap({ (path) -> URL? in
                return URL(fileURLWithPath: path)
            })
            .flatMap({ (url) -> Data? in
                return try! Data(contentsOf: url)
            })
            .flatMap { (data) -> Structure? in
                try! JSONDecoder().decode(Structure.self, from: data)
            }
        
        let root = MainMenu()
        root.structure = structure
        
        self.setViewControllers([root], animated: false)
    }
}

