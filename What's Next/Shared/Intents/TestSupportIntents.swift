//
//  TestSupportIntents.swift
//  What's Next
//
//  Created by Hundter Biede on 10/9/26.
//  Copyright © 2026 com.hbiede. All rights reserved.
//

#if DEBUG
import AppIntents
import CoreData

/// Lets the AppIntentsTesting tests in What's NextUITests remove what they added, without the confirmation
/// `DeleteRecommendationsIntent` asks for
struct RemoveTestRecommendationsIntent: AppIntent {
    static let title: LocalizedStringResource = "Remove Test Recommendations"
    static let isDiscoverable = false
    static let supportedModes: IntentModes = .background

    @Parameter(title: "Title prefix")
    var namePrefix: String

    @MainActor
    func perform() async throws -> some IntentResult {
        let request = Item.fetchRequest()
        request.predicate = NSPredicate(format: "name BEGINSWITH %@", namePrefix)
        let identifiers = try PersistenceController.shared.container.viewContext.fetch(request).compactMap(\.id)
        try deleteRecommendations(withIDs: identifiers)
        RecommendationSync.shared.syncNow()
        return .result()
    }
}
#endif
