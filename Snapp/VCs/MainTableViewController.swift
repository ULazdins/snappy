//
//  MainTableViewController.swift
//  Snapp
//
//  Created by Uģis Lazdiņš on 09/07/2019.
//  Copyright © 2019 Uģis Lazdiņš. All rights reserved.
//

import UIKit
import RxSwift

struct CellData {
    let title: String
    let subtitle: String?
    let imageUrl: String?
}

class MainTableViewController: UITableViewController {
    var screen: Screen!
    private var source: [CellData] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    private func setSourceFrom(data: [String: Any]) {
        let keys = screen.pathToList.split(separator: ".").map(String.init)
        
        var unwrappedData = data
        for key in keys.dropLast(1) {
            print(key)
            unwrappedData = unwrappedData[key] as! [String: Any]
            print(unwrappedData)
        }
        
        let a = unwrappedData[keys.last!] as! [[String: Any]]
        
        source = a.map({ (aa) -> CellData in
            return CellData(
                title: aa[screen.cellKeys.title] as? String ?? "",
                subtitle: screen.cellKeys.subtitle.map { aa[$0] as? String ?? "" },
                imageUrl: screen.cellKeys.imageUrl.map { aa[$0] as? String ?? "" }
            )
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _ = GithubClient()
            .fetchData(query: screen.query)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: self.setSourceFrom)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = source[indexPath.row].title
        cell.detailTextLabel?.text = source[indexPath.row].title
        return cell
    }
}
