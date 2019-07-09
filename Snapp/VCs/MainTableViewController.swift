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
    let rawData: [String: Any]
}

class MainTableViewController: UITableViewController {
    var screen: TableScreen!
    var structure: Structure!
    private var source: [CellData] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    private func setSourceFrom(data: [String: Any]) {
        let keys = screen.pathToList.split(separator: ".").map(String.init)
        
        let a = keys
            .dropLast(1)
            .reduce(data) { (data, key) -> [String: Any] in
                return data[key] as! [String: Any]
            }
            ==> {
                $0[keys.last!] as! [[String: Any]]
            }
        
        source = a.map({ (aa) -> CellData in
            return CellData(
                title: aa[screen.cellKeys.title] as? String ?? "",
                subtitle: screen.cellKeys.subtitle.map { aa[$0] as? String ?? "" },
                imageUrl: screen.cellKeys.imageUrl.map { aa[$0] as? String ?? "" },
                rawData: aa
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
        let cell = UITableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: nil)
        cell.textLabel?.text = source[indexPath.row].title
        cell.detailTextLabel?.text = source[indexPath.row].title
        cell.imageView!.image = UIImage(named: "person.png")!
        source[indexPath.row].imageUrl.flatMap(URL.init(string:)).map { cell.imageView?.downloadImage(from: $0) }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let cellTapAction = screen.cellTapAction else { return }
        
        let target = structure.screens.first { (s) -> Bool in
            s.id == cellTapAction.screenId
        }
        
        if let target = target as? DetailsStackScreen {
            let vc = DetailsViewController()
            vc.screen = target
            
            let titleKey = cellTapAction.params["title"] ?? ""
            let cellInfo = source[indexPath.row]
            vc.mainTitle = cellInfo.rawData[titleKey] as? String
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
