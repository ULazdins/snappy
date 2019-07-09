//
//  Screens.swift
//  Snapp
//
//  Created by Uģis Lazdiņš on 09/07/2019.
//  Copyright © 2019 Uģis Lazdiņš. All rights reserved.
//

import Foundation


class Screen: Decodable {
    let id: String
    let query: String
}

class TableScreen: Screen {
    let pathToList: String
    let cellKeys: CellKeys
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pathToList = try container.decode(String.self, forKey: .pathToList)
        cellKeys = try container.decode(CellKeys.self, forKey: .cellKeys)
        try super.init(from: decoder)
    }
    
    enum CodingKeys : String, CodingKey {
        case id
        case type
        case query
        case pathToList = "path-to-list"
        case cellKeys = "cell-keys"
    }
}

class DetailsStackScreen: Screen {
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}

enum ScreenFamily: String, ClassFamily {
    case Table = "table"
    case DetailsStack = "details-stack"
    
    static var discriminator: Discriminator = .type
    
    func getType() -> AnyObject.Type {
        switch self {
        case .DetailsStack:
            return DetailsStackScreen.self
        case .Table:
            return TableScreen.self
        }
    }
}
