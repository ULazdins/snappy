//
//  GraphQlClient.swift
//  Snapp
//
//  Created by Uģis Lazdiņš on 09/07/2019.
//  Copyright © 2019 Uģis Lazdiņš. All rights reserved.
//

import RxSwift
import RxCocoa

struct GraphQlRequest: Codable {
    let query: String
    let variables: [String: String]
    
    init(query: String, variables: [String: String] = [:]) {
        self.query = query
        self.variables = variables
    }
    
    func toString() -> String {
        let jsonData = try! JSONEncoder().encode(self)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        return jsonString
    }
}

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
    
    func fetchData(request: GraphQlRequest) -> Observable<[String: Any]> {
        print("-->", request)
        let r = NSMutableURLRequest(url: URL(string: graphQlUrl)!)
        r.httpMethod = "POST"
        r.setValue(bearerToken.map({ "Bearer \($0)" }) ?? "", forHTTPHeaderField: "Authorization")
        r.setValue("application/json", forHTTPHeaderField: "Content-Type")
        r.httpBody = request.toString().data(using: .utf8)
        
        return Observable.create { (observer) -> Disposable in
            let task = URLSession.shared.dataTask(with: r as URLRequest) { (data, response, error) in
                if let error = error {
                    print("<--", error.localizedDescription)
                    observer.onError(error)
                    return
                }
                
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
