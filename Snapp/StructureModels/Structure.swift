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
    let iconName: String?
    let screenId: String
    
    enum CodingKeys : String, CodingKey {
        case title
        case iconName
        case screenId
    }
}

struct Menu: Decodable {
    let items: [MenuItem]
}


struct CellKeys: Decodable {
    let title: String
    let subtitle: String?
    let imageUrl: String?
}

class Structure: Decodable {
    let menu: Menu
    let screens: [Screen]
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StructureCodingKeys.self)
        menu = try container.decode(Menu.self, forKey: .menu)
        screens = try container.decode(family: ScreenFamily.self, forKey: .screens)
    }
    
    enum StructureCodingKeys: String, CodingKey {
        case menu
        case screens
    }
}

