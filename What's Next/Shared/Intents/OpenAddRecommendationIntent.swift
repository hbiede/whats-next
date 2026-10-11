//
//  OpenAddRecommendationIntent.swift
//  What's Next
//
//  Created by Hundter Biede on 10/9/26.
//  Copyright © 2026 com.hbiede. All rights reserved.
//

import AppIntents

/// Opens the Add Recommendation screen. Shared with the widget extension for the Control Center control.
struct OpenAddRecommendationIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Add Recommendation"
    static let description = IntentDescription("Open What's Next to add a recommendation.")
    static let supportedModes: IntentModes = .foreground

    @MainActor
    func perform() async throws -> some IntentResult {
        QuickActionSettings.shared.quickAction = .ADD_REC
        return .result()
    }
}
