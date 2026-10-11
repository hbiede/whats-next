//
//  Types.swift
//  WidgetExtension
//
//  Created by Hundter Biede on 11/8/22.
//  Copyright © 2022 com.hbiede. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit

extension Color {
    /// The app's accent color; WidgetKit renders `Color.accentColor` as the system blue
    static let appAccent = Color("AccentColor")
}

extension View {
    /// Since iOS 17, WidgetKit draws a placeholder asking for `containerBackground` in place of any widget without
    /// one. The system removes it on the Lock Screen and in tinted and clear modes.
    func widgetBackground(for family: WidgetFamily) -> some View {
        containerBackground(for: .widget) {
            switch family {
            case .accessoryCircular, .accessoryCorner, .accessoryInline, .accessoryRectangular:
                Color.clear
            default:
                Color("WidgetBackground")
            }
        }
    }
}

extension WidgetRecommendation {
    /// Stands in for real recommendations in placeholders and the widget gallery
    static func sample(_ type: RecType) -> WidgetRecommendation {
        switch type {
        case .movie:
            return WidgetRecommendation(
                id: UUID(),
                name: NSLocalizedString("toy-story-title", comment: "Toy Story title"),
                type: type,
                author: nil,
                recommender: NSLocalizedString("toy-story-recommender", comment: "Who recommender Toy Story"),
                recommendationDate: Date()
            )
        case .tvShow:
            return WidgetRecommendation(
                id: UUID(),
                name: NSLocalizedString("breaking-bad-title", comment: "Breaking Bad title"),
                type: type,
                author: nil,
                recommender: NSLocalizedString("breaking-bad-recommender", comment: "Who recommender Breaking Bad"),
                recommendationDate: Date()
            )
        case .book:
            return WidgetRecommendation(
                id: UUID(),
                name: NSLocalizedString("sample-book-title", comment: "Sample book title"),
                type: type,
                author: NSLocalizedString("sample-book-author", comment: "Sample book author"),
                recommender: NSLocalizedString("parks-and-rec-recommender", comment: "Who recommender Parks and Rec"),
                recommendationDate: Date()
            )
        }
    }
}
