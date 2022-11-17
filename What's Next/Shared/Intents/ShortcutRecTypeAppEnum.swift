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
enum ShortcutRecTypeAppEnum: String, AppEnum {
    case movie
    case tvShow
    case book

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Recommendation Type")
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .movie: .init(stringLiteral: ShortcutRecTypeAppEnum.movie.rawValue),
        .tvShow: .init(stringLiteral: ShortcutRecTypeAppEnum.tvShow.rawValue),
        .book: .init(stringLiteral: ShortcutRecTypeAppEnum.book.rawValue)
    ]

    var description: String {
        return self.rawValue
    }
}

