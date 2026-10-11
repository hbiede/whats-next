//
//  SingleWidgetView.swift
//  WidgetExtension
//
//  Created by Hundter Biede on 11/8/22.
//  Copyright © 2022 com.hbiede. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit

struct WhatsNextSingleWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily

    var entry: SingleWidgetProvider.Entry

    // MARK: Body
    var body: some View {
        content
            .widgetURL(getURL())
            .widgetBackground(for: widgetFamily)
    }

    @ViewBuilder
    private var content: some View {
        switch widgetFamily {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 0) {
                    Image(systemName: entry.type.systemImage)
                        .font(.caption)
                        .widgetAccentable()
                    Text(entry.count, format: .number)
                        .multilineTextAlignment(.center)
                        .font(.title2.weight(.semibold))
                        .minimumScaleFactor(0.5)
                }
            }
        case .accessoryInline:
            Label {
                Text(entry.count, format: .number)
            } icon: {
                Image(systemName: entry.type.systemImage)
            }
        default:
            ZStack {
                Circle()
                    .fill(Color.appAccent)
                    .widgetAccentable()
                VStack {
                    Image(systemName: entry.type.systemImage)
                        .font(.title3)
                        .hidden()
                    Text(entry.count, format: .number)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .font(.system(size: 500))
                        .minimumScaleFactor(0.01)
                    Image(systemName: entry.type.systemImage)
                        .font(.title3)
                        .foregroundStyle(.white)
                }
                .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
            }
                .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
        }
    }

    // MARK: Get Tap URL
    func getURL() -> URL? {
        return URL(
            string: entry.count == 0
                ? QuickActionSettings.ShortcutAction.ADD_REC.rawValue
                : QuickActionSettings.ShortcutAction.GET_REC.rawValue
        )
    }
}

struct WhatsNextSingleWidget: Widget {
    let kind: String = SINGLE_WIDGET_KIND

    var body: some WidgetConfiguration {
        return AppIntentConfiguration(
            kind: kind,
            intent: SingleWidgetConfigurationIntent.self,
            provider: SingleWidgetProvider()
        ) { entry in
            WhatsNextSingleWidgetEntryView(entry: entry)
                .unredacted()
        }
            .configurationDisplayName(NSLocalizedString("app-title", comment: "App title"))
            .description(
                NSLocalizedString(
                    "single-widget-desc",
                    comment: "The description display on single widget selection screen"
                )
            )
            .supportedFamilies([
                .systemSmall,
                .systemMedium,
                .accessoryCircular,
                .accessoryInline,
            ])
    }
}

#Preview(as: .systemSmall) {
    WhatsNextSingleWidget()
} timeline: {
    WhatsNextSingleEntry(date: Date(), type: .movie, count: 4)
}

#Preview(as: .accessoryCircular) {
    WhatsNextSingleWidget()
} timeline: {
    WhatsNextSingleEntry(date: Date(), type: .book, count: 12)
}
