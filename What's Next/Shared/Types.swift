//
//  Types.swift
//  What's Next
//
//  Created by Hundter Biede on 6/17/21.
//

import AppIntents
import Foundation

nonisolated enum RecType: String, CustomStringConvertible, CaseIterable, Codable, Hashable, Identifiable, Sendable {
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
    var pluralDescription: String {
        switch self {
        case .movie: return "movie-plural"
        case .tvShow: return "tvShow-plural"
        case .book: return "book-plural"
        }
    }
    var noRecordsDescription: String {
        switch self {
        case .movie: return "no-movie-records-text"
        case .tvShow: return "no-tv-records-text"
        case .book: return "no-book-records-text"
        }
    }
    var emoji: String {
        switch self {
        case .movie: return "🎥"
        case .tvShow: return "📺"
        case .book: return "📚"
        }
    }
    /// SF Symbol for the type; unlike the emoji, it takes on the tint in tinted and clear widgets
    var systemImage: String {
        switch self {
        case .movie: return "film"
        case .tvShow: return "tv"
        case .book: return "book.closed"
        }
    }
}

extension RecType: AppEnum {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Recommendation Type")
    static let caseDisplayRepresentations: [RecType: DisplayRepresentation] = [
        .movie: DisplayRepresentation(
            title: "movie",
            image: .init(systemName: "film"),
            synonyms: ["movie-synonym-film"]
        ),
        .tvShow: DisplayRepresentation(
            title: "tvShow",
            image: .init(systemName: "tv"),
            synonyms: ["tvShow-synonym-show", "tvShow-synonym-series"]
        ),
        .book: DisplayRepresentation(
            title: "book",
            image: .init(systemName: "book.closed"),
            synonyms: ["book-synonym-novel"]
        )
    ]
}
