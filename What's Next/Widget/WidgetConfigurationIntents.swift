//
//  WidgetConfigurationIntents.swift
//  WidgetExtension
//
//  Created by Hundter Biede on 10/9/26.
//  Copyright © 2026 com.hbiede. All rights reserved.
//

import AppIntents
import WidgetKit

/// Replaces the `ParameterizedConfiguration` SiriKit intent. Migrating keeps the type people chose for widgets they
/// had already placed, since the parameter name and enum cases match.
struct SingleWidgetConfigurationIntent: WidgetConfigurationIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "ParameterizedConfigurationIntent"
    static let title: LocalizedStringResource = "Recommendation Type"

    @Parameter(title: "Recommendation Type", default: .movie)
    var recType: RecType
}

/// Replaces the `CombinedConfiguration` SiriKit intent, which had no parameters
struct CombinedWidgetConfigurationIntent: WidgetConfigurationIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "CombinedConfigurationIntent"
    static let title: LocalizedStringResource = "Recommendation Counts"
}

struct PickWidgetConfigurationIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Recommendation Type"

    @Parameter(title: "Recommendation Type", default: .movie)
    var recommendationType: RecType

    init() {}

    init(recommendationType: RecType) {
        self.recommendationType = recommendationType
    }
}
