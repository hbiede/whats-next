//
//  DeleteRecommendationsIntent.swift
//  What's Next
//
//  Created by Hundter Biede on 10/9/26.
//  Copyright © 2026 com.hbiede. All rights reserved.
//

import AppIntents
import CoreData

/// Lets Siri act on requests like "delete this one" for the recommendation on screen
struct DeleteRecommendationsIntent: DeleteIntent {
    static let title: LocalizedStringResource = "Delete Recommendations"
    static let supportedModes: IntentModes = .background

    @Parameter(title: "Recommendations")
    var entities: [RecommendationEntity]

    static var parameterSummary: some ParameterSummary {
        Summary("Delete \(\.$entities)")
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let dialog: IntentDialog = if entities.count == 1, let entity = entities.first {
            "Delete \(entity.name)?"
        } else {
            "Delete \(entities.count) recommendations?"
        }
        try await requestConfirmation(
            actionName: .custom(
                acceptLabel: "delete-recommnedation-button",
                acceptAlternatives: [],
                denyLabel: "Cancel",
                denyAlternatives: [],
                destructive: true
            ),
            dialog: dialog
        )
        try deleteRecommendations(withIDs: entities.map(\.id))
        RecommendationSync.shared.syncNow()
        return .result()
    }
}

func deleteRecommendations(withIDs identifiers: [UUID]) throws {
    let viewContext = PersistenceController.shared.container.viewContext
    let request = Item.fetchRequest()
    request.predicate = NSPredicate(format: "id IN %@", argumentArray: [identifiers])
    try viewContext.fetch(request).forEach(viewContext.delete)
    try viewContext.save()
}
