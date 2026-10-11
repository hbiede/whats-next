//
//  RecommendationSync.swift
//  What's Next
//
//  Created by Hundter Biede on 10/9/26.
//  Copyright © 2026 com.hbiede. All rights reserved.
//

import CoreData
import CoreSpotlight
import WidgetKit

/// Keeps the copies of the recommendations outside the app (the widgets' snapshot and the Spotlight index) in step
/// with Core Data. It listens for saves and for changes CloudKit imports, so screens and intents don't have to
/// remember to update them.
final class RecommendationSync {
    static let shared = RecommendationSync()

    private var observers: [NSObjectProtocol] = []
    private var pendingUpdate: Task<Void, Never>?
    private var spotlightUpdate: Task<Void, Never>?
    private let spotlight = SpotlightIndexer()

    func start(persistence: PersistenceController = .shared) {
        guard observers.isEmpty else { return }
        let center = NotificationCenter.default
        let onChange: @Sendable (Notification) -> Void = { _ in
            MainActor.assumeIsolated { RecommendationSync.shared.scheduleUpdate() }
        }
        observers = [
            center.addObserver(
                forName: NSManagedObjectContext.didSaveObjectsNotification,
                object: persistence.container.viewContext,
                queue: .main,
                using: onChange
            ),
            center.addObserver(
                forName: .NSPersistentStoreRemoteChange,
                object: persistence.container.persistentStoreCoordinator,
                queue: .main,
                using: onChange
            )
        ]
        scheduleUpdate()
    }

    /// Updates straight away. For App Intents, since the system may suspend the app as soon as they return.
    func syncNow() {
        pendingUpdate?.cancel()
        update()
    }

    private func scheduleUpdate() {
        // A burst of saves or CloudKit imports only needs one update
        pendingUpdate?.cancel()
        pendingUpdate = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            update()
        }
    }

    private func update() {
        let request = Item.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.recommendationDate, ascending: true)]
        guard let items = try? PersistenceController.shared.container.viewContext.fetch(request) else { return }

        #if os(iOS)
        if SharedRecommendations.save(items.compactMap(WidgetRecommendation.init(item:))) {
            WidgetCenter.shared.reloadAllTimelines()
        }
        #endif

        // Each Spotlight update waits for the one before, so they apply in order
        let entities = items.compactMap(RecommendationEntity.init(item:))
        spotlightUpdate = Task { [previousUpdate = spotlightUpdate, spotlight] in
            await previousUpdate?.value
            await spotlight.index(entities)
        }
    }
}

/// Spotlight work stays off the main actor and nothing waits for it: the first indexing call in a process can take
/// minutes while Spotlight's semantic index starts up.
private actor SpotlightIndexer {
    /// What's in Spotlight; `nil` until the first update clears out whatever an earlier launch left there
    private var indexedIDs: Set<UUID>?

    func index(_ entities: [RecommendationEntity]) async {
        let currentIDs = Set(entities.map(\.id))
        let index = CSSearchableIndex.default()
        do {
            if let indexedIDs {
                let removedIDs = Array(indexedIDs.subtracting(currentIDs))
                if !removedIDs.isEmpty {
                    try await index.deleteAppEntities(identifiedBy: removedIDs, ofType: RecommendationEntity.self)
                }
            } else {
                try await index.deleteAppEntities(ofType: RecommendationEntity.self)
            }
            try await index.indexAppEntities(entities)
            indexedIDs = currentIDs
        } catch {
            print("Failed to update Spotlight: \(error)")
        }
    }
}

extension WidgetRecommendation {
    @MainActor
    init?(item: Item) {
        guard let id = item.id, let name = item.name, let type = item.type.flatMap(RecType.init(rawValue:)) else {
            return nil
        }
        self.init(
            id: id,
            name: name,
            type: type,
            author: item.author,
            recommender: item.recommender,
            recommendationDate: item.recommendationDate
        )
    }
}
