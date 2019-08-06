//
//  Structure.swift
//  Snapp
//
//  Created by Uģis Lazdiņš on 09/07/2019.
//  Copyright © 2019 Uģis Lazdiņš. All rights reserved.
//

import Foundation
import UIKit

struct Theme: Decodable {
    let primaryColor: String
    let secondaryColor: String
    let prefersLargeTitles: Bool
}

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
    let theme: Theme
    let graphQlUrl: String!
    let apiUrl: String!
    let graphQlAuthToken: String?
    let menu: Menu
    let screens: [Screen]
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StructureCodingKeys.self)
        theme = try container.decode(Theme.self, forKey: .theme)
        graphQlUrl = try? container.decode(String.self, forKey: .graphQlUrl)
        apiUrl = try? container.decode(String.self, forKey: .apiUrl)
        graphQlAuthToken = try? container.decode(String.self, forKey: .graphQlAuthToken)
        menu = try container.decode(Menu.self, forKey: .menu)
        screens = try container.decode(family: ScreenFamily.self, forKey: .screens)
    }
    
    enum StructureCodingKeys: String, CodingKey {
        case theme
        case graphQlUrl
        case apiUrl
        case graphQlAuthToken
        case menu
        case screens
    }
}

