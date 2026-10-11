//
//  SingleWidget.swift
//  WidgetExtension
//
//  Created by Hundter Biede on 11/8/22.
//  Copyright © 2022 com.hbiede. All rights reserved.
//

import WidgetKit
import SwiftUI

struct SingleWidgetProvider: AppIntentTimelineProvider {
    typealias Entry = WhatsNextSingleEntry

    typealias Intent = SingleWidgetConfigurationIntent

    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), type: .movie, count: 3)
    }

    func snapshot(for configuration: Intent, in context: Context) async -> Entry {
        entry(for: configuration)
    }

    func timeline(for configuration: Intent, in context: Context) async -> Timeline<Entry> {
        // The app reloads widgets whenever its recommendations change
        Timeline(entries: [entry(for: configuration)], policy: .never)
    }

    private func entry(for configuration: Intent) -> Entry {
        Entry(
            date: Date(),
            type: configuration.recType,
            count: SharedRecommendations.counts()[configuration.recType, default: 0]
        )
    }
}

struct WhatsNextSingleEntry: TimelineEntry {
    let date: Date
    let type: RecType
    let count: Int
}
