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



extension Dictionary where Key == String, Value == Any {
    private func reducer(acc: [String: Any]?, key: String) -> [String: Any]? {
        guard let acc = acc else {
            return [:]
        }
        guard let nextValue = acc[key] else {
            print("Couldn't find key: \(key)")
            print("Available keys: \(acc.keys)")
            return [:]
        }
        guard let parsedValue = nextValue as? [String: Any] else {
            print("Couldn't parse value: \(nextValue) to type `[String: Any]`")
            print("Value is of type: \(nextValue.self)")
            return [:]
        }
        return parsedValue
    }
    
    func getDict(at path: String) -> [String: Any]? {
        let keys = path.split(separator: ".").map(String.init)
        
        return keys.reduce(self, reducer)
    }
    
    func getArray(at path: String) -> [[String: Any]]? {
        let keys = path.split(separator: ".").map(String.init)
        
        return keys
            .dropLast(1)
            .reduce(self, reducer)
            .map {
                $0[keys.last!] as? [[String: Any]] ?? []
            } ?? []
    }
    
    func getValue(at path: String) -> String {
        let keys = path.split(separator: ".").map(String.init)
        
        return keys
            .dropLast(1)
            .reduce(self, reducer)
            .map {
                $0[keys.last!] as? String ?? ""
            } ?? ""
    }
}
