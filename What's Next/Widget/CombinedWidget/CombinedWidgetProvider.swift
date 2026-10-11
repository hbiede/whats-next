//
//  Widget.swift
//  Widget
//
//  Created by Hundter Biede on 11/7/22.
//  Copyright © 2022 com.hbiede. All rights reserved.
//

import WidgetKit
import SwiftUI

struct CombinedWidgetProvider: AppIntentTimelineProvider {
    typealias Entry = WhatsNextCombinedEntry

    typealias Intent = CombinedWidgetConfigurationIntent

    func placeholder(in context: Context) -> Entry {
        Entry(
            date: Date(),
            counts: [.movie: 3, .tvShow: 2, .book: 1],
            recommendations: RecType.allCases.map(WidgetRecommendation.sample)
        )
    }

    func snapshot(for configuration: Intent, in context: Context) async -> Entry {
        entry()
    }

    func timeline(for configuration: Intent, in context: Context) async -> Timeline<Entry> {
        // The app reloads widgets whenever its recommendations change
        Timeline(entries: [entry()], policy: .never)
    }

    private func entry() -> Entry {
        Entry(
            date: Date(),
            counts: SharedRecommendations.counts(),
            recommendations: (SharedRecommendations.load() ?? []).reversed()
        )
    }
}

struct WhatsNextCombinedEntry: TimelineEntry {
    let date: Date
    let counts: [RecType: Int]
    /// Newest first, for the list in the extra large layout
    let recommendations: [WidgetRecommendation]

    var isEmpty: Bool {
        counts.values.allSatisfy { $0 == 0 }
    }
}
