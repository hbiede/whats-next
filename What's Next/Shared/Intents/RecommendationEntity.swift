//
//  RecommendationEntity.swift
//  What's Next
//
//  Created by Hundter Biede on 10/9/26.
//  Copyright © 2026 com.hbiede. All rights reserved.
//

import AppIntents
import CoreData
import CoreSpotlight

/// A recommendation as Siri, Shortcuts and Spotlight see it. Indexing it lets Siri find recommendations by what they
/// mean, and annotating views with its identifier lets Siri act on the one on screen.
struct RecommendationEntity: IndexedEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(
        name: "Recommendation",
        numericFormat: "\(placeholder: .int) recommendations"
    )
    static let defaultQuery = RecommendationQuery()

    let id: UUID

    @Property(title: "Title")
    var name: String

    @Property(title: "Type")
    var type: RecType

    @Property(title: "Author")
    var author: String?

    @Property(title: "Recommended by")
    var recommender: String?

    @Property(title: "Recommended on")
    var recommendedOn: Date?

    @Property(title: "Notes")
    var notes: String?

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(name)",
            subtitle: recommender.flatMap { $0.isEmpty ? nil : "recommender-listing \($0)" },
            image: .init(systemName: type.systemImage)
        )
    }

    var attributeSet: CSSearchableItemAttributeSet {
        let attributes = CSSearchableItemAttributeSet(contentType: .content)
        attributes.displayName = name
        attributes.contentDescription = notes
        attributes.contentCreationDate = recommendedOn
        attributes.keywords = [NSLocalizedString(type.description, comment: "The name of the type")]
            + [author, recommender].compactMap { $0?.isEmpty == false ? $0 : nil }
        return attributes
    }

    @MainActor
    init?(item: Item) {
        guard let id = item.id, let name = item.name, let type = item.type.flatMap(RecType.init(rawValue:)) else {
            return nil
        }
        self.id = id
        self.name = name
        self.type = type
        self.author = item.author
        self.recommender = item.recommender
        self.recommendedOn = item.recommendationDate
        self.notes = item.notes
    }

    static func identifier(for id: UUID) -> EntityIdentifier {
        EntityIdentifier(for: RecommendationEntity.self, identifier: id)
    }
}

struct RecommendationQuery: EntityStringQuery {
    @MainActor
    func entities(for identifiers: [UUID]) async throws -> [RecommendationEntity] {
        try fetch(NSPredicate(format: "id IN %@", argumentArray: [identifiers]))
    }

    @MainActor
    func entities(matching string: String) async throws -> [RecommendationEntity] {
        try fetch(NSPredicate(
            format: "name CONTAINS[cd] %@ OR author CONTAINS[cd] %@ OR recommender CONTAINS[cd] %@",
            string,
            string,
            string
        ))
    }

    @MainActor
    func suggestedEntities() async throws -> [RecommendationEntity] {
        try fetch(nil)
    }

    @MainActor
    func entities(ofType type: RecType) throws -> [RecommendationEntity] {
        try fetch(NSPredicate(format: "type == %@", type.description))
    }

    @MainActor
    private func fetch(_ predicate: NSPredicate?) throws -> [RecommendationEntity] {
        try fetchRecommendations(predicate)
    }
}

// Outside `RecommendationQuery`, where `Item` would mean `EntityQuery.Item` rather than the Core Data entity
private func fetchRecommendations(_ predicate: NSPredicate?) throws -> [RecommendationEntity] {
    let request = Item.fetchRequest()
    request.predicate = predicate
    request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.recommendationDate, ascending: true)]
    return try PersistenceController.shared.container.viewContext
        .fetch(request)
        .compactMap(RecommendationEntity.init(item:))
}
