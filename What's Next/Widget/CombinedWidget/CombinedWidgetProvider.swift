//
//  Widget.swift
//  Widget
//
//  Created by Hundter Biede on 11/7/22.
//  Copyright © 2022 com.hbiede. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

struct CombinedWidgetProvider: IntentTimelineProvider {
    typealias Entry = WhatsNextCombinedEntry

    typealias Intent = CombinedConfigurationIntent

    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), configuration: Intent())
    }

    func getSnapshot(
        for configuration: Intent,
        in context: Context,
        completion: @escaping (Entry) -> ()
    ) {
        completion(
            Entry(date: Date(), configuration: configuration)
        )
    }

    func getTimeline(
        for configuration: Intent,
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> ()
    ) {
        let timeline = Timeline(
            entries: [Entry(date: Date(), configuration: configuration)],
            policy: .atEnd
        )
        completion(timeline)
    }
}

struct WhatsNextCombinedEntry: TimelineEntry {
    let date: Date
    let configuration: CombinedConfigurationIntent
}
