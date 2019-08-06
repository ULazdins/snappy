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
    let rawData: Any
}


class MainTableViewController: UITableViewController {
    var screen: TableScreen!
    var structure: Structure!
    var graphQlClient: GraphQlClient!
    var plainApiClient: PlainApiClient!
    private var source: [CellData] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var searchDisposable: Disposable? = nil
    
    private func setSourceFrom(data: Any) {
        let listItem = traverseJson(json: data, path: screen.pathToList) as? [Any] ?? []
        
        source = listItem.map({ (item) -> CellData in
            return CellData(
                title: traverseJson(json: item, path: screen.cellKeys.title) as? String ?? "",
                subtitle: screen.cellKeys.subtitle.flatMap { traverseJson(json: item, path: $0) as? String },
                imageUrl: screen.cellKeys.imageUrl.flatMap { traverseJson(json: item, path: $0) as? String },
                rawData: item
            )
        })
    }
    
    var search: UISearchController {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        if let textFieldInsideSearchBar = search.searchBar.value(forKey: "searchField") as? UITextField {
            textFieldInsideSearchBar.textColor = UIColor(hex: structure.theme.secondaryColor)
        }
        return search
    }
    
    lazy var searchBar:UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
    
    var loaded = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        definesPresentationContext = true
        
        if !loaded {
            navigationItem.title = screen.title
            
            if screen.searchable {
                self.navigationItem.searchController = search
            }
            
            if structure.graphQlUrl != nil {
                searchDisposable = graphQlClient!
                    .fetchData(request: GraphQlRequest(query: screen.query!, variables: ["q": ""]))
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: self.setSourceFrom)
            } else {
                searchDisposable = plainApiClient!
                    .fetchData(request: PlainApiRequest(path: screen.apiPath!))
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: self.setSourceFrom)
            }
        }
        
        registerForPreviewing(with: self, sourceView: tableView)
        
        loaded = true
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
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = source[indexPath.row].title
        cell.detailTextLabel?.text = source[indexPath.row].subtitle
        cell.imageView!.image = UIImage(named: "person.png")
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
        vc.structure = structure
        vc.graphQlClient = graphQlClient
        vc.plainApiClient = plainApiClient
        
        let titleKey = cellTapAction.params["title"] ?? ""
        vc.mainTitle = traverseJson(json: cellInfo, path: titleKey) as? String
        
        vc.parameters = Dictionary(uniqueKeysWithValues: cellTapAction.params
            .map { key, value in
                (key, traverseJson(json: cellInfo.rawData, path: value) as? String ?? "")
            })
        
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

extension MainTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print("Typed", searchController.searchBar.text)
        
        if let query = searchController.searchBar.text, query.count > 0 {
            searchDisposable?.dispose()
            if structure.graphQlUrl != nil {
                searchDisposable = graphQlClient!
                    .fetchData(request: GraphQlRequest(query: screen.query!, variables: ["q": query]))
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: self.setSourceFrom)
            } else {
                searchDisposable = plainApiClient!
                    .fetchData(request: PlainApiRequest(path: screen.apiPath!, variables: ["search": query]))
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: self.setSourceFrom)
            }
        }
    }
}
