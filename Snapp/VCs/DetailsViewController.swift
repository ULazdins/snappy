//
//  DetailsViewController.swift
//  Snapp
//
//  Created by Uģis Lazdiņš on 09/07/2019.
//  Copyright © 2019 Uģis Lazdiņš. All rights reserved.
//

import UIKit
import RxSwift

class DetailsViewController: UIViewController {
    var screen: DetailsStackScreen!
    var structure: Structure!
    var parameters: [String: String] = [:]
    var mainTitle: String!
    var graphQlClient: GraphQlClient!
    var plainApiClient: PlainApiClient!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = mainTitle
    }
    
    var imageView: UIImageView! = nil
    
    func replaceQueryParameters(query: String) -> String {
        let pattern = #"(<\w+>)"#
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let fullRange = NSRange(query.startIndex..<query.endIndex, in: query)
        let matches = regex.matches(in: query, options: [], range: fullRange)
        
        var resultQuery = query
        for match in matches {
            let firstCaptureRange: Range<String.Index> = Range(match.range(at: 1), in: resultQuery)!
            let placeholder = (resultQuery)[firstCaptureRange]
            let key: String = String(placeholder.dropFirst().dropLast())
            let value = parameters[key] ?? ""
            
            resultQuery = resultQuery.replacingOccurrences(of: placeholder, with: value)
        }
        return resultQuery
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if structure.graphQlUrl != nil {
            let query = replaceQueryParameters(query: screen.query!)
            
            _ = graphQlClient!
                .fetchData(request: GraphQlRequest(query: query))
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { (data) in
                    let personDetails = traverseJson(json: data, path: self.screen.pathToDetails) as? [String: Any]
                    
                    (personDetails?["avatarUrl"] as? String)
                        .flatMap(URL.init(string:))
                        .map(self.imageView!.downloadImage)
                })
        } else {
            let query = replaceQueryParameters(query: screen.apiPath!)
            
            _ = plainApiClient!
                .fetchData(request: PlainApiRequest(path: query))
//                .observeOn(MainScheduler.instance)
//                .subscribe(onNext: { (data) in
//                    let personDetails = data.getDict(at: self.screen.pathToDetails)
//                    
//                    (personDetails?["avatarUrl"] as? String)
//                        .flatMap(URL.init(string:))
//                        .map(self.imageView!.downloadImage)
//                })
        }
        
        scrollView.delegate = self
        
        imageView = UIImageView()
        c = imageView.heightAnchor.constraint(equalToConstant: 300)
        c.isActive = true
        imageView.image = UIImage(named: "person.png")
        
        
        view.addSubview(scrollView)
        scrollView.addSubview(scrollViewContainer)
        scrollViewContainer.addArrangedSubview(imageView)
        scrollViewContainer.addArrangedSubview(redView)
        scrollViewContainer.addArrangedSubview(blueView)
        scrollViewContainer.addArrangedSubview(greenView)
        
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        scrollViewContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        scrollViewContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        scrollViewContainer.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        scrollViewContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        // this is important for scrolling
        scrollViewContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    let scrollViewContainer: UIStackView = {
        let view = UIStackView()
        
        view.axis = .vertical
        view.spacing = 10
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var c: NSLayoutConstraint! = nil
    
    let redView: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 500).isActive = true
        view.backgroundColor = .red
        return view
    }()
    
    let blueView: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 200).isActive = true
        view.backgroundColor = .blue
        return view
    }()
    
    let greenView: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 1200).isActive = true
        view.backgroundColor = .green
        return view
    }()
}

// https://stackoverflow.com/a/46727061/683763
extension DetailsViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let c = c else { return }
        
        let offset = scrollView.contentOffset
        
        if offset.y < 0.0 {
            var transform = CATransform3DTranslate(CATransform3DIdentity, 0, offset.y, 0)
            let scaleFactor = 1 + (-1 * offset.y / (c.constant / 2))
            transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1)
            imageView.layer.transform = transform
        } else {
            imageView.layer.transform = CATransform3DIdentity
        }
    }
}
