//
//  Filterer.swift
//  What's Next
//
//  Created by Hundter Biede on 6/30/21.
//  Copyright © 2021 com.hbiede. All rights reserved.
//

import Foundation
import CoreData

func sortItems(items: [Item], sortMethod: String) -> Dictionary<String, [Item]> {
    var result: [String : [Item]] = [:]
    items.forEach { item in
        if item.type != nil {
            if result[item.type!] == nil {
                result[item.type!] = []
            }
            result[item.type!]!.append(item)
        }
    }
    return result
}
