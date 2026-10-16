//
//  PickWidgetProvider.swift
//  WidgetExtension
//
//  Created by Hundter Biede on 10/9/26.
//  Copyright © 2026 com.hbiede. All rights reserved.
//

import AppIntents
import WidgetKit

struct PickWidgetProvider: AppIntentTimelineProvider {
    typealias Entry = PickEntry

    typealias Intent = PickWidgetConfigurationIntent

    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), type: .movie, recommendation: .sample(.movie), canShuffle: true)
    }

    func snapshot(for configuration: Intent, in context: Context) async -> Entry {
        let entry = entry(for: configuration)
        // Show the gallery what the widget does even before anything's been added
        if context.isPreview && entry.recommendation == nil {
            let type = configuration.recommendationType
            return Entry(date: Date(), type: type, recommendation: .sample(type), canShuffle: true)
        }
        return entry
    }

    func timeline(for configuration: Intent, in context: Context) async -> Timeline<Entry> {
        // A fresh pick each day; the app reloads sooner when its recommendations change
        // Adding a calendar day, not 24 hours, so it's still midnight when the clocks change
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today.addingTimeInterval(24 * 60 * 60)
        return Timeline(entries: [entry(for: configuration)], policy: .after(tomorrow))
    }

    private func entry(for configuration: Intent) -> Entry {
        let type = configuration.recommendationType
        let recommendations = SharedRecommendations.load() ?? []
        return Entry(
            date: Date(),
            type: type,
            recommendation: SharedRecommendations.pick(for: type, in: recommendations),
            canShuffle: recommendations.filter { $0.type == type }.count > 1
        )
    }
}

struct PickEntry: TimelineEntry {
    let date: Date
    let type: RecType
    let recommendation: WidgetRecommendation?
    let canShuffle: Bool
}

/// Run by the widget's shuffle button, in the widget extension; WidgetKit reloads the widget afterwards
struct ShuffleRecommendationIntent: AppIntent {
    static let title: LocalizedStringResource = "Shuffle Recommendation"
    static let isDiscoverable = false

    @Parameter(title: "Recommendation Type", default: .movie)
    var recommendationType: RecType

    init() {}

    init(recommendationType: RecType) {
        self.recommendationType = recommendationType
    }

    func perform() async throws -> some IntentResult {
        SharedRecommendations.shuffle(recommendationType)
        return .result()
    }
}
