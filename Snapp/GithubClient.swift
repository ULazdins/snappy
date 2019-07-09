//
//  GithubClient.swift
//  Snapp
//
//  Created by Uģis Lazdiņš on 09/07/2019.
//  Copyright © 2019 Uģis Lazdiņš. All rights reserved.
//

import RxSwift
import RxCocoa

class GithubClient {
    private func dataToJson(data: Data) -> [String: Any] {
        return (try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any])!
    }
    
    func fetchData(query: String) -> Observable<[String: Any]> {
        let r = NSMutableURLRequest(url: URL.init(string: "https://api.github.com/graphql")!)
        r.httpMethod = "POST"
        r.setValue("Bearer 02fbffadfd9586e8216b30cf6bc6b81080c48e97", forHTTPHeaderField: "Authorization")
        r.httpBody = "{\"query\": \"\(query)\"}".data(using: .utf8)
        
        return Observable.create { (observer) -> Disposable in
            let task = URLSession.shared.dataTask(with: r as URLRequest) { (data, response, error) in
                observer.on(.next(self.dataToJson(data: data!)))
                observer.on(.completed)
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
