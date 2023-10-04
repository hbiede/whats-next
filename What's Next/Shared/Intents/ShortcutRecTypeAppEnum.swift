//
//  ShortcutRecTypeAppEnum.swift
//  What's Next
//
//  Created by Hundter Biede on 11/16/22.
//  Copyright © 2022 com.hbiede. All rights reserved.
//

import AppIntents
import Foundation

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
enum ShortcutRecTypeAppEnum: String, AppEnum, ExpressibleByNilLiteral {
    init(nilLiteral: ()) {
        self = .movie
    }
    
    case movie
    case tvShow
    case book

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Recommendation Type")
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .movie: .init(title: "movie"),
        .tvShow: .init(title: "tvShow"),
        .book: .init(title: "book")
    ]

    var description: String {
        return self.rawValue
    }
}

