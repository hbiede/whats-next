//
//  Types.swift
//  WidgetExtension
//
//  Created by Hundter Biede on 11/8/22.
//  Copyright © 2022 com.hbiede. All rights reserved.
//

import Foundation

class ConvertedCounts: ObservableObject {
    @Published var movieCount: Int = 0
    @Published var tvShowCount: Int = 0
    @Published var bookCount: Int = 0
    
    func count() -> Int {
        return movieCount + tvShowCount + bookCount
    }
    
    func count(type: RecType) -> Int {
        switch type {
        case .book:
            return bookCount
        case .tvShow:
            return bookCount
        default:
            return bookCount
        }
    }
    
    func isEmpty() -> Bool {
        return self.count() == 0
    }
    
    func isEmpty(type: RecType) -> Bool {
        self.count(type: type) == 0
    }
}
