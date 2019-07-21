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
    var graphQlClient: GraphQlClient!
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
        
        _ = graphQlClient!
            .fetchData(query: screen.query)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: self.setSourceFrom)
        
        registerForPreviewing(with: self, sourceView: tableView)
    }
}

extension MainTableViewController {
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
            let vc = createDetailsStackScreen(target: target, cellInfo: source[indexPath.row], cellTapAction: cellTapAction)
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func createDetailsStackScreen(target: DetailsStackScreen, cellInfo: CellData, cellTapAction: CellTapAction) -> DetailsViewController {
        let vc = DetailsViewController()
        vc.screen = target
        vc.graphQlClient = graphQlClient
        
        let titleKey = cellTapAction.params["title"] ?? ""
        vc.mainTitle = cellInfo.rawData[titleKey] as? String
        
        vc.parameters = Dictionary(uniqueKeysWithValues: cellTapAction.params.map { key, value in (key, cellInfo.rawData[value] as? String ?? "")})
        
        return vc
    }
}

extension MainTableViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location) {
            previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
            
            guard let cellTapAction = screen.cellTapAction else { return nil }
            
            let target = structure.screens.first { cellTapAction.screenId == $0.id }
            if let target = target as? DetailsStackScreen {
                return createDetailsStackScreen(target: target, cellInfo: source[indexPath.row], cellTapAction: cellTapAction)
            }
        }
        
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}
