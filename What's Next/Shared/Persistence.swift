//
//  Persistence.swift
//  Shared
//
//  Created by Hundter Biede on 6/17/21.
//

import CoreData

// MARK: Save to iCloud
struct PersistenceController {
    #if DEBUG
    /// UI tests and fastlane's screenshots launch with this, to start from an empty store that's never saved or synced
    static let isUITesting = CommandLine.arguments.contains("-ui_testing")
    #else
    static let isUITesting = false
    #endif

    static let shared = PersistenceController(inMemory: isUITesting)

    #if DEBUG
    /**
     * Generates fake items for the UI previews
     */
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for itemCounter in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.id = UUID()
            newItem.name = "Test \(itemCounter)"
            newItem.recommendationDate = Date()
            newItem.recommender = "Recommender \(itemCounter)"
            if Bool.random() {
                newItem.type = RecType.movie.description
            } else {
                newItem.type = RecType.book.description
                newItem.author = "Author \(itemCounter)"
            }

        }
        let newTV = Item(context: viewContext)
        newTV.id = UUID()
        newTV.name = "Test 11"
        newTV.recommendationDate = Date()
        newTV.recommender = "Recommender 11"
        newTV.type = RecType.tvShow.description

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    #endif

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "What_s_Next")
        let description = container.persistentStoreDescriptions.first!
        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
            description.cloudKitContainerOptions = nil
        }
        // Announce changes CloudKit imports, so `RecommendationSync` can pass them on to widgets and Spotlight
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                #if DEBUG
                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection
                *   when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
                #else
                print(error.localizedDescription)
                #endif
            }
        })
        // Show changes from other devices as soon as CloudKit imports them
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
}
