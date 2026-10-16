//
//  WidgetView.swift
//  WidgetExtension
//
//  Created by Hundter Biede on 11/7/22.
//  Copyright © 2022 com.hbiede. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit

struct WhatsNextCombinedWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily

    var entry: CombinedWidgetProvider.Entry

    var body: some View {
        content
            .widgetURL(QuickActionSettings.url(for: entry.isEmpty ? .ADD_REC : .GET_REC))
            .widgetBackground(for: widgetFamily)
    }

    @ViewBuilder
    private var content: some View {
        if entry.isEmpty {
            Text(
                NSLocalizedString("add-rec-screen-title", comment: "Title name for Add Recommendation screen")
            )
                .foregroundStyle(Color.appAccent)
                .font(.title2.weight(.semibold))
                .widgetAccentable()
        } else if widgetFamily == .systemMedium {
            counts
        } else {
            VStack(alignment: .leading, spacing: 24) {
                counts
                    .frame(maxWidth: .infinity)
                recentRecommendations
            }
        }
    }

    private var counts: some View {
        let movieCount = entry.counts[.movie, default: 0]
        let tvShowCount = entry.counts[.tvShow, default: 0]
        let bookCount = entry.counts[.book, default: 0]
        return HStack(alignment: .center, spacing: 48) {
            CountView(
                count: movieCount,
                type: .movie,
                leftDivider: tvShowCount > 0 || bookCount > 0
            )
            CountView(
                count: tvShowCount,
                type: .tvShow,
                leftDivider: bookCount > 0
            )
            CountView(
                count: bookCount,
                type: .book
            )
        }
    }

    // MARK: Extra Large Portrait
    private var recentRecommendations: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(RecType.allCases) { type in
                let recommendations = entry.recommendations.filter { $0.type == type }.prefix(4)
                if !recommendations.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(
                            NSLocalizedString(type.pluralDescription, comment: "The plural name of the type"),
                            systemImage: type.systemImage
                        )
                            .font(.headline)
                            .foregroundStyle(Color.appAccent)
                            .widgetAccentable()
                        ForEach(recommendations) { recommendation in
                            if let url = QuickActionSettings.url(opening: recommendation.id) {
                                Link(destination: url) {
                                    RecommendationRow(recommendation: recommendation)
                                }
                            }
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
    }
}

private struct RecommendationRow: View {
    let recommendation: WidgetRecommendation

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(recommendation.name)
                .font(.body.weight(.semibold))
                .lineLimit(1)
            if let recommender = recommendation.recommender, !recommender.isEmpty {
                Text("recommender-listing \(recommender)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

struct WhatsNextCombinedWidget: Widget {
    let kind: String = COMBINED_WIDGET_KIND

    var body: some WidgetConfiguration {
        return AppIntentConfiguration(
            kind: kind,
            intent: CombinedWidgetConfigurationIntent.self,
            provider: CombinedWidgetProvider()
        ) { entry in
            WhatsNextCombinedWidgetEntryView(entry: entry)
                .unredacted()
        }
            .configurationDisplayName(NSLocalizedString("app-title", comment: "App title"))
            .description(
                NSLocalizedString(
                    "widget-desc",
                    comment: "The description display on widget selection screen"
                )
            )
            .supportedFamilies(supportedFamilies)
    }

    private var supportedFamilies: [WidgetFamily] {
        if #available(iOS 27.0, *) {
            return [.systemMedium, .systemExtraLargePortrait]
        } else {
            return [.systemMedium]
        }
    }
}

#Preview(as: .systemMedium) {
    WhatsNextCombinedWidget()
} timeline: {
    WhatsNextCombinedEntry(
        date: Date(),
        counts: [.movie: 3, .tvShow: 2, .book: 1],
        recommendations: RecType.allCases.map(WidgetRecommendation.sample)
    )
}
