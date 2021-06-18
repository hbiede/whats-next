//
//  Types.swift
//  What's Next
//
//  Created by Hundter Biede on 6/17/21.
//

import Foundation

enum Type: String, CustomStringConvertible, CaseIterable, Hashable, Identifiable {
    var id: String { self.rawValue }

    case movie
    case tvShow
    case book

    var description: String {
        switch self {
        case .movie: return "Movie"
        case .tvShow: return "TV Show"
        case .book: return "Book"
        }
      }
    var sentenceDescription: String {
        switch self {
        case .movie: return "Movie"
        case .tvShow: return "TV show"
        case .book: return "Book"
        }
      }
    var midSentenceDescription: String {
        switch self {
        case .movie: return "movie"
        case .tvShow: return "TV show"
        case .book: return "book"
        }
      }
}
