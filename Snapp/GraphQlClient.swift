//
//  GraphQlClient.swift
//  Snapp
//
//  Created by Uģis Lazdiņš on 09/07/2019.
//  Copyright © 2019 Uģis Lazdiņš. All rights reserved.
//

import RxSwift
import RxCocoa

class GraphQlClient {
    let graphQlUrl: String
    let bearerToken: String?
    
    init(graphQlUrl: String, bearerToken: String?) {
        self.graphQlUrl = graphQlUrl
        self.bearerToken = bearerToken
    }
    
    private func dataToJson(data: Data) -> [String: Any] {
        return (try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any])!
    }
    
    func fetchData(query: String) -> Observable<[String: Any]> {
        print("-->", query)
        let r = NSMutableURLRequest(url: URL(string: graphQlUrl)!)
        r.httpMethod = "POST"
        r.setValue(bearerToken.map({ "Bearer \($0)" }) ?? "", forHTTPHeaderField: "Authorization")
        r.setValue("application/json", forHTTPHeaderField: "Content-Type")
        r.httpBody = "{\"query\": \"\(query.replacingOccurrences(of: "\"", with: "\\\""))\"}".data(using: .utf8)
        
        return Observable.create { (observer) -> Disposable in
            let task = URLSession.shared.dataTask(with: r as URLRequest) { (data, response, error) in
                print("<--", String(data: data!, encoding: .utf8)!)
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
