//
//  OpenRecommendationIntent.swift
//  What's Next
//
//  Created by Hundter Biede on 10/9/26.
//  Copyright © 2026 com.hbiede. All rights reserved.
//

import AppIntents

/// Opens a recommendation's detail screen, e.g. from a Spotlight result or when Siri is asked to show one
struct OpenRecommendationIntent: OpenIntent {
    static let title: LocalizedStringResource = "Open Recommendation"
    static let supportedModes: IntentModes = .foreground

    @Parameter(title: "Recommendation")
    var target: RecommendationEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        QuickActionSettings.shared.recommendationToOpen = target.id
        return .result()
    }
}
