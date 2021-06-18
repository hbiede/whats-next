//
//  Persistence.swift
//  Shared
//
//  Created by Hundter Biede on 6/17/21.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    /**
     * Generates fake items for the UI previews
     */
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for itemCounter in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.name = "Test \(itemCounter)"
            newItem.recommendationDate = Date()
            newItem.recommender = "Recommender \(itemCounter)"
            if arc4random() < RAND_MAX {
                newItem.type = "Movie" as String
            } else {
                newItem.type = "Book" as String
                newItem.author = "Author \(itemCounter)"
            }

        }
        let newTV = Item(context: viewContext)
        newTV.name = "Test 11"
        newTV.recommendationDate = Date()
        newTV.recommender = "Recommender 11"
        newTV.type = "TV Show" as String

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            #if DEBUG
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            #else
            print(nsError.localizedDescription)
            #endif
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "What_s_Next")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
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
    }
}
