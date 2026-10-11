//
//  PickWidgetView.swift
//  WidgetExtension
//
//  Created by Hundter Biede on 10/9/26.
//  Copyright © 2026 com.hbiede. All rights reserved.
//

import AppIntents
import SwiftUI
import WidgetKit

/// Shows one recommendation to try next, with a button to shuffle for another
struct PickWidgetView: View {
    @Environment(\.widgetFamily) var widgetFamily

    var entry: PickWidgetProvider.Entry

    var body: some View {
        content
            .widgetURL(url)
            .widgetBackground(for: widgetFamily)
    }

    @ViewBuilder
    private var content: some View {
        switch widgetFamily {
        case .accessoryInline:
            if let recommendation = entry.recommendation {
                Label(recommendation.name, systemImage: entry.type.systemImage)
            } else {
                Label(NSLocalizedString("add-rec-title", comment: "Add a recommendation"), systemImage: "plus")
            }
        case .accessoryRectangular:
            VStack(alignment: .leading) {
                Label(
                    NSLocalizedString("up-next-page-title", comment: "Title name for Up Next screen"),
                    systemImage: entry.type.systemImage
                )
                    .font(.headline)
                    .widgetAccentable()
                if let recommendation = entry.recommendation {
                    Text(recommendation.name)
                        .lineLimit(2)
                } else {
                    Text(NSLocalizedString(entry.type.noRecordsDescription, comment: "No records found"))
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        default:
            VStack(alignment: .leading, spacing: 4) {
                header
                Spacer(minLength: 0)
                if let recommendation = entry.recommendation {
                    details(of: recommendation)
                } else {
                    Text(NSLocalizedString(entry.type.noRecordsDescription, comment: "No records found"))
                        .font(.headline)
                    Text(NSLocalizedString("add-rec-title", comment: "Add a recommendation"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appAccent)
                        .widgetAccentable()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            Label(
                NSLocalizedString(entry.type.description, comment: "Convert the type to a title cased string"),
                systemImage: entry.type.systemImage
            )
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appAccent)
                .widgetAccentable()
            Spacer(minLength: 4)
            if entry.canShuffle {
                Button(intent: ShuffleRecommendationIntent(recommendationType: entry.type)) {
                    Image(systemName: "shuffle")
                        .font(.caption.weight(.semibold))
                        .accessibilityLabel(
                            NSLocalizedString("shuffle-button-label", comment: "Show a different recommendation")
                        )
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
                .tint(Color.appAccent)
                .widgetAccentable()
            }
        }
    }

    @ViewBuilder
    private func details(of recommendation: WidgetRecommendation) -> some View {
        Text(recommendation.name)
            .font(widgetFamily == .systemSmall ? .headline : .title2)
            .fontWeight(.bold)
            .lineLimit(3)
            .minimumScaleFactor(0.7)
        // The small widget drops the "Author:" and "Recommended by:" labels, which leave no room for the names
        if recommendation.type == .book, let author = recommendation.author, !author.isEmpty {
            Group {
                if widgetFamily == .systemSmall {
                    Text(author)
                } else {
                    Text("author-listing \(author)")
                }
            }
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        if let recommender = recommendation.recommender, !recommender.isEmpty {
            Group {
                if widgetFamily == .systemSmall {
                    Label(recommender, systemImage: "person")
                } else {
                    Text("recommender-listing \(recommender)")
                }
            }
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    private var url: URL? {
        if let recommendation = entry.recommendation {
            return QuickActionSettings.url(opening: recommendation.id)
        }
        return URL(string: QuickActionSettings.ShortcutAction.ADD_REC.rawValue)
    }
}

struct WhatsNextPickWidget: Widget {
    let kind: String = PICK_WIDGET_KIND

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: PickWidgetConfigurationIntent.self,
            provider: PickWidgetProvider()
        ) { entry in
            PickWidgetView(entry: entry)
        }
            .configurationDisplayName(NSLocalizedString("up-next-page-title", comment: "Title name for Up Next screen"))
            .description(
                NSLocalizedString(
                    "pick-widget-desc",
                    comment: "The description display on Up Next widget selection screen"
                )
            )
            .supportedFamilies([
                .systemSmall,
                .systemMedium,
                .accessoryRectangular,
                .accessoryInline
            ])
    }
}

#Preview(as: .systemSmall) {
    WhatsNextPickWidget()
} timeline: {
    PickEntry(date: Date(), type: .movie, recommendation: .sample(.movie), canShuffle: true)
    PickEntry(date: Date(), type: .book, recommendation: .sample(.book), canShuffle: true)
    PickEntry(date: Date(), type: .tvShow, recommendation: nil, canShuffle: false)
}

#Preview(as: .accessoryRectangular) {
    WhatsNextPickWidget()
} timeline: {
    PickEntry(date: Date(), type: .movie, recommendation: .sample(.movie), canShuffle: true)
}
