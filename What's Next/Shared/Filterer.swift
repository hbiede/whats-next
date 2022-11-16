//
//  Filterer.swift
//  What's Next
//
//  Created by Hundter Biede on 6/30/21.
//  Copyright © 2021 com.hbiede. All rights reserved.
//

import Foundation
import CoreData

func sortItems(items: [Item], sortMethod: String) -> [String: [Item]] {
    return items.reduce(into: [:]) { acc, item in
        if item.type != nil {
            acc[item.type!, default: []].append(item)
        }
    }
}
