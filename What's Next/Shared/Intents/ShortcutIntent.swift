//
//  ShortcutIntent.swift
//  What's Next
//
//  Created by Hundter Biede on 11/16/22.
//  Copyright © 2022 com.hbiede. All rights reserved.
//

import Foundation
import AppIntents

struct ShortcutIntent: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "ShortcutIntent"
    static let supportedModes: IntentModes = .background

    static let title: LocalizedStringResource = "Add Recommendation"
    static let description: IntentDescription = .init("Add Recommendation to What's Next")

    @Parameter(title: "Recommendation Type", default: .movie)
    var recommendationType: RecType

    @Parameter(title: "Author")
    var author: String?

    @Parameter(title: "Title")
    var name: String

    @Parameter(title: "Recommended by")
    var recommender: String?

    @Parameter(title: "Recommended on")
    var recommendedOn: Date?

    @Parameter(title: "Notes")
    var notes: String?

    static var parameterSummary: some ParameterSummary {
        When(\.$recommendationType, .equalTo, .book) {
            Summary {
                \.$recommendationType
                \.$name
                \.$author
                \.$recommender
                \.$recommendedOn
                \.$notes
            }
        } otherwise: {
            Summary {
                \.$recommendationType
                \.$name
                \.$recommender
                \.$recommendedOn
                \.$notes
            }
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<RecommendationEntity> {
        // Hold to what the Add Recommendation screen requires: a title, and an author for books only
        let title = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            throw $name.needsValueError()
        }
        let bookAuthor = recommendationType == .book
            ? (author ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            : ""
        if recommendationType == .book && bookAuthor.isEmpty {
            throw $author.needsValueError()
        }

        let viewContext = PersistenceController.shared.container.viewContext
        let newItem = Item(context: viewContext)
        newItem.id = UUID()
        newItem.name = title
        newItem.author = bookAuthor
        newItem.recommender = recommender == nil
                                ? ""
                                : recommender!.trimmingCharacters(in: .whitespacesAndNewlines)
        // The Add Recommendation screen doesn't allow future dates either
        newItem.recommendationDate = min(recommendedOn ?? Date(), Date())
        newItem.notes = notes == nil ? "" : notes!.trimmingCharacters(in: .whitespacesAndNewlines)
        newItem.type = recommendationType.description
        do {
            try viewContext.save()
        } catch {
            print("Failed to save new item")
            viewContext.rollback()
            throw ShortcutIntentSaveError.saveError
        }
        RecommendationSync.shared.syncNow()
        guard let entity = RecommendationEntity(item: newItem) else {
            throw ShortcutIntentSaveError.saveError
        }
        return .result(value: entity)
    }
}

extension ShortcutIntent {
    init(recommendationType: RecType? = nil) {
        self.recommendationType = recommendationType ?? .movie
    }
}

enum ShortcutIntentSaveError: Swift.Error, CustomLocalizedStringResourceConvertible {
    case saveError

    var localizedStringResource: LocalizedStringResource {
        LocalizedStringResource(
            stringLiteral: NSLocalizedString(
                "failed-to-save-shortcut",
                comment: "Shortcut error message"
            )
        )
    }
}
