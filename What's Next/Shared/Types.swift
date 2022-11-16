//
//  Types.swift
//  What's Next
//
//  Created by Hundter Biede on 6/17/21.
//

import Foundation

enum RecType: String, CustomStringConvertible, CaseIterable, Hashable, Identifiable {
    var id: String { self.rawValue }

    case movie
    case tvShow
    case book

    var description: String {
        switch self {
        case .movie: return "movie"
        case .tvShow: return "tvShow"
        case .book: return "book"
        }
      }
    var sentenceDescription: String {
        switch self {
        case .movie: return "movie-sentence-start"
        case .tvShow: return "tvShow-sentence-start"
        case .book: return "book-sentence-start"
        }
      }
    var midSentenceDescription: String {
        switch self {
        case .movie: return "movie-mid-sentence"
        case .tvShow: return "tvShow-mid-sentence"
        case .book: return "book-mid-sentence"
        }
      }
    var emoji: String {
        switch self {
        case .movie: return "🎥"
        case .tvShow: return "📺"
        case .book: return "📚"
        }
    }
}
