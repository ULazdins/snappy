//
//  PlainApiClient.swift
//  Snapp
//
//  Created by Uģis Lazdiņš on 30/07/2019.
//  Copyright © 2019 Uģis Lazdiņš. All rights reserved.
//

import RxSwift
import RxCocoa

struct PlainApiRequest: Codable {
    let path: String
    let variables: [String: String]
    
    init(path: String, variables: [String: String] = [:]) {
        self.path = path
        self.variables = variables
    }
    
    func toString() -> String {
        let jsonData = try! JSONEncoder().encode(self)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        return jsonString
    }
}

class PlainApiClient {
    let apiUrl: String
    
    init(apiUrl: String) {
        self.apiUrl = apiUrl
    }
    
    func fetchData(request: PlainApiRequest) -> Observable<Any> {
        print("-->", request)
        var urlComponents = URLComponents(string: apiUrl + request.path)!
        urlComponents.queryItems = request.variables.map(URLQueryItem.init)
        let r = NSMutableURLRequest(url: urlComponents.url!)
        r.httpMethod = "GET"
        
        r.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return Observable.create { (observer) -> Disposable in
            let task = URLSession.shared.dataTask(with: r as URLRequest) { (data, response, error) in
                if let error = error {
                    print("<--", error.localizedDescription)
                    observer.onError(error)
                    return
                }
                
                print("<--", String(data: data!, encoding: .utf8)!)
                observer.on(.next(try! JSONSerialization.jsonObject(with: data!, options: [])))
                observer.on(.completed)
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
}
