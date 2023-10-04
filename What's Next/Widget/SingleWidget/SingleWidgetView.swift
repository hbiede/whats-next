//
//  SingleWidgetView.swift
//  WidgetExtension
//
//  Created by Hundter Biede on 11/8/22.
//  Copyright © 2022 com.hbiede. All rights reserved.
//

import CoreData
import Foundation
import SwiftUI
import WidgetKit

struct WhatsNextSingleWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily

    var entry: SingleWidgetProvider.Entry
    
    @StateObject private var recCounts: ConvertedCounts = ConvertedCounts()
    @State private var selectionType: RecType = .movie

    // MARK: Body
    @ViewBuilder
    var body: some View {
        switch widgetFamily {
        case .accessoryCircular:
            ZStack {
                Circle()
                    .foregroundColor(.accentColor)
                Text("\(recCounts.count(type: selectionType))")
                    .multilineTextAlignment(.center)
                    .font(.title)
            }
                .widgetURL(getURL())
                .onAppear(perform: onAppear)
        default:
            ZStack {
                Circle()
                    .foregroundColor(.accentColor)
                VStack {
                    Text("")
                        .accessibilityHidden(true)
                        .font(.title3)
                    Text("\(recCounts.count(type: selectionType))")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .font(.system(size: 500))
                        .minimumScaleFactor(0.01)
                    Text(selectionType.emoji)
                        .font(.title3)
                }
                .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
            }
                .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                .widgetURL(getURL())
                .onAppear(perform: onAppear)
        }
    }
    
    // MARK: Appear - Data Load
    func onAppear() {
        switch entry.configuration.recType {
        case .book:
            selectionType = .book
        case .tvShow:
            selectionType = .tvShow
        default:
            selectionType = .movie
        }
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
    
    // MARK: Get Tap URL
    func getURL() -> URL? {
        return URL(
            string: recCounts.isEmpty(type: selectionType)
                ? QuickActionSettings.ShortcutAction.ADD_REC.rawValue
                : QuickActionSettings.ShortcutAction.GET_REC.rawValue
        )
    }
}

struct WhatsNextSingleWidget: Widget {
    let kind: String = SINGLE_WIDGET_KIND

    var body: some WidgetConfiguration {
        return IntentConfiguration(
            kind: kind,
            intent: ParameterizedConfigurationIntent.self,
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
            .supportedFamilies(supportedFamilies())
    }
    
    func supportedFamilies() -> [WidgetFamily] {
        if #available(iOS 16, *) {
            return [
                .systemSmall,
                .systemMedium,
                .accessoryCircular,
            ]
        } else {
            return [
                .systemSmall,
                .systemMedium,
            ]
        }
    }
}

#if DEBUG
struct WhatsNextSingleWidgetPreviews: PreviewProvider {
    static var previews: some View {
        WhatsNextSingleWidgetEntryView(
            entry: WhatsNextSingleEntry(date: Date(),
                                        configuration: ParameterizedConfigurationIntent()
                                    )
        )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
#endif
