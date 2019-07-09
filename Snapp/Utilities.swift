//
//  Utilities.swift
//  Snapp
//
//  Created by Uģis Lazdiņš on 09/07/2019.
//  Copyright © 2019 Uģis Lazdiņš. All rights reserved.
//

import UIKit

infix operator ==>

func ==><T, U>(value: T, f: (T) -> U) -> U {
    return f(value)
}


extension UIImageView {
    func downloadImage(from url: URL) {
        DispatchQueue.global(qos: .background).async {
            print("Download Started")
            
            let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
                guard let data = data, error == nil else { return }
                print("Download Finished")
                DispatchQueue.main.async() {
                    self.image = UIImage(data: data)
                }
            })
            
            task.resume()
        }
    }
}

