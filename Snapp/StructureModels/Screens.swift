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
    let query: String?
    let apiPath: String?
    let title: String
}

class CellTapAction: Decodable {
    let screenId: String
    let params: [String: String]
}

class TableScreen: Screen {
    let searchable: Bool
    let pathToList: String
    let cellKeys: CellKeys
    let cellTapAction: CellTapAction?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        searchable = (try? container.decode(Bool.self, forKey: .searchable)) ?? false
        pathToList = try container.decode(String.self, forKey: .pathToList)
        cellKeys = try container.decode(CellKeys.self, forKey: .cellKeys)
        cellTapAction = try? container.decode(CellTapAction.self, forKey: .cellTapAction)
        try super.init(from: decoder)
    }
    
    enum CodingKeys : String, CodingKey {
        case id
        case type
        case query
        case searchable
        case pathToList
        case cellKeys
        case cellTapAction
    }
}

class DetailsStackScreen: Screen {
    let pathToDetails: String
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pathToDetails = try container.decode(String.self, forKey: .pathToDetails)
        try super.init(from: decoder)
    }
    
    enum CodingKeys : String, CodingKey {
        case pathToDetails
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
