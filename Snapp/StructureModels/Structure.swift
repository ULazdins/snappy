//
//  Structure.swift
//  Snapp
//
//  Created by Uģis Lazdiņš on 09/07/2019.
//  Copyright © 2019 Uģis Lazdiņš. All rights reserved.
//

import Foundation

struct MenuItem: Decodable {
    let title: String
    let screenId: String
    
    enum CodingKeys : String, CodingKey {
        case title
        case screenId = "screen-id"
    }
}

struct Menu: Decodable {
    let items: [MenuItem]
}

enum ScreenType: String, Decodable {
    case Table = "table"
}

struct CellKeys: Decodable {
    let title: String
    let subtitle: String?
    let imageUrl: String?
}

struct Screen: Decodable {
    let id: String
    let type: ScreenType
    let query: String
    let pathToList: String
    let cellKeys: CellKeys
    
    enum CodingKeys : String, CodingKey {
        case id
        case type
        case query
        case pathToList = "path-to-list"
        case cellKeys = "cell-keys"
    }
}

struct Structure: Decodable {
    let menu: Menu
    let screens: [Screen]
}

