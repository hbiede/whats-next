//
//  ShortcutIntent.swift
//  What's Next
//
//  Created by Hundter Biede on 11/16/22.
//  Copyright © 2022 com.hbiede. All rights reserved.
//

import Foundation
import AppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct ShortcutIntent: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "ShortcutIntent"
    static var openAppWhenRun: Bool = false

    static var title: LocalizedStringResource = "Add Recommendation"
    static var description: IntentDescription = .init("Add Recommendation to What's Next")

    @Parameter(title: "Recommendation Type", default: .movie)
    var recommendationType: ShortcutRecTypeAppEnum

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
    func perform() async throws -> some IntentResult {
        // TODO: Place your refactored intent handler code here.
        let viewContext = PersistenceController.shared.container.viewContext
        let newItem = Item(context: viewContext)
        newItem.id = UUID()
        newItem.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        newItem.author = author == nil ? "" : author!.trimmingCharacters(in: .whitespacesAndNewlines)
        newItem.recommender = recommender == nil
                                ? ""
                                : recommender!.trimmingCharacters(in: .whitespacesAndNewlines)
        newItem.recommendationDate = recommendedOn ?? Date()
        newItem.notes = notes == nil ? "" : notes!.trimmingCharacters(in: .whitespacesAndNewlines)
        newItem.type = RecType(
                            rawValue: recommendationType.rawValue
                        )?.description ?? ShortcutRecTypeAppEnum.movie.rawValue
        do {
            try viewContext.save()
            saveItemCounts(context: viewContext)
        } catch {
            print("Failed to save new item")
            throw ShortcutIntentSaveError.saveError
        }
        return .result()
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
extension ShortcutIntent {
    init(recommendationType: ShortcutRecTypeAppEnum? = nil) {
        self.recommendationType = recommendationType ?? .movie
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
fileprivate extension IntentDialog {
    static func recommendationTypeParameterDisambiguationIntro(count: Int, recommendationType: ShortcutRecTypeAppEnum) -> Self {
        "There are \(count) options matching ‘\(recommendationType)’."
    }
    static func recommendationTypeParameterConfirmation(recommendationType: ShortcutRecTypeAppEnum) -> Self {
        "Just to confirm, you wanted ‘\(recommendationType)’?"
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
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

