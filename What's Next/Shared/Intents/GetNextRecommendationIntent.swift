//
//  GetNextRecommendationIntent.swift
//  What's Next
//
//  Created by Hundter Biede on 10/9/26.
//  Copyright © 2026 com.hbiede. All rights reserved.
//

import AppIntents
import Foundation

/// The app's main feature, the random pick from the Up Next screen, for Siri, Shortcuts and Spotlight
struct GetNextRecommendationIntent: AppIntent {
    static let title: LocalizedStringResource = "Get What's Next"
    static let description = IntentDescription("Pick a random recommendation to try next.")
    static let supportedModes: IntentModes = .background

    @Parameter(title: "Recommendation Type", default: .movie)
    var recommendationType: RecType

    static var parameterSummary: some ParameterSummary {
        Summary("Pick a random \(\.$recommendationType)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<RecommendationEntity> & ProvidesDialog {
        guard let pick = try RecommendationQuery().entities(ofType: recommendationType).randomElement() else {
            throw NoRecommendationsError(type: recommendationType)
        }
        let dialog: IntentDialog = if let recommender = pick.recommender, !recommender.isEmpty {
            "Try \(pick.name), recommended by \(recommender)."
        } else {
            "Try \(pick.name)."
        }
        return .result(value: pick, dialog: dialog)
    }
}

struct NoRecommendationsError: Error, CustomLocalizedStringResourceConvertible {
    let type: RecType

    var localizedStringResource: LocalizedStringResource {
        LocalizedStringResource(
            stringLiteral: NSLocalizedString(type.noRecordsDescription, comment: "No records found")
        )
    }
}
