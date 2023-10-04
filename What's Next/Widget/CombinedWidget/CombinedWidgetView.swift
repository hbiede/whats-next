//
//  WidgetView.swift
//  WidgetExtension
//
//  Created by Hundter Biede on 11/7/22.
//  Copyright © 2022 com.hbiede. All rights reserved.
//

import CoreData
import Foundation
import SwiftUI
import WidgetKit

struct WhatsNextCombinedWidgetEntryView: View {
    var entry: CombinedWidgetProvider.Entry
    
    @StateObject private var recCounts: ConvertedCounts = ConvertedCounts()

    @ViewBuilder
    var body: some View {
        HStack(alignment: .center, spacing: 48) {
            if recCounts.isEmpty() {
                Text(
                    NSLocalizedString("add-rec-screen-title", comment: "Title name for Add Recommendation screen")
                )
                    .foregroundColor(.accentColor)
                    .font(.title2.weight(.semibold))
            } else {
                CountView(
                    count: recCounts.movieCount,
                    type: RecType.movie.emoji,
                    leftDivider: recCounts.tvShowCount > 0 || recCounts.bookCount > 0
                )
                CountView(
                    count: recCounts.tvShowCount,
                    type: RecType.tvShow.emoji,
                    leftDivider: recCounts.bookCount > 0
                )
                CountView(
                    count: recCounts.bookCount,
                    type: RecType.book.emoji
                )
            }
        }
        .widgetURL(
            URL(
                string: recCounts.isEmpty()
                    ? QuickActionSettings.ShortcutAction.ADD_REC.rawValue
                    : QuickActionSettings.ShortcutAction.GET_REC.rawValue
            )
        )
        .onAppear {
            if let userDefaults = UserDefaults(suiteName: APP_GROUP) {
                guard let testcreateEvent = userDefaults.object(forKey: WIDGET_COUNT_KEY) as? NSData else {
                    print("Data not found in UserDefaults")
                    return
                }
            
                do {
                    guard let countsDict =
                        try NSKeyedUnarchiver.unarchivedObject(ofClass: NSMutableDictionary.self, from: testcreateEvent as Data) else {
                                fatalError("Cannot load countsDict")
                            }
                
                    recCounts.movieCount = countsDict.object(forKey: RecType.movie.description) as? Int ?? 0
                    recCounts.tvShowCount = countsDict.object(forKey: RecType.tvShow.description) as? Int ?? 0
                    recCounts.bookCount = countsDict.object(forKey: RecType.book.description) as? Int ?? 0
                } catch {
                    fatalError("countsDict - Can't dencode data: \(error)")
                }
            }
        }
    }
}

struct WhatsNextCombinedWidget: Widget {
    let kind: String = COMBINED_WIDGET_KIND

    var body: some WidgetConfiguration {
        return IntentConfiguration(
            kind: kind,
            intent: CombinedConfigurationIntent.self,
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
            .supportedFamilies([
                .systemMedium,
            ])
    }
}

#if DEBUG
struct WhatsNextCombinedWidgetPreviews: PreviewProvider {
    static var previews: some View {
        WhatsNextCombinedWidgetEntryView(
            entry: WhatsNextCombinedEntry(date: Date(),
                                          configuration: CombinedConfigurationIntent()
                                        )
        )
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
#endif
