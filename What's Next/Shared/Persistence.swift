//
//  Persistence.swift
//  Shared
//
//  Created by Hundter Biede on 6/17/21.
//

import CoreData
import WidgetKit

// MARK: Save to app group
func saveItemCounts(context: NSManagedObjectContext) {
    if let userDefaults = UserDefaults(suiteName: APP_GROUP) {
        var items: [Item] = []
        do {
            try items = context.fetch(Item.fetchRequest())
        } catch {
            print("X \(error)")
            return
        }
        let countsDict = NSMutableDictionary()
        let recCountsAccumulator = items.reduce(into: [:]) { acc, item in
            acc[item.type!, default: 0] += 1
        }
        recCountsAccumulator.keys.forEach { key in
            countsDict.setValue(recCountsAccumulator[key, default: 0], forKey: key)
        }

        let resultDic = try? NSKeyedArchiver.archivedData(
            withRootObject: countsDict,
            requiringSecureCoding: false
        )
        userDefaults.set(resultDic, forKey: WIDGET_COUNT_KEY)
        WidgetCenter.shared.reloadTimelines(ofKind: COMBINED_WIDGET_KIND)
        WidgetCenter.shared.reloadTimelines(ofKind: SINGLE_WIDGET_KIND)
    }
}

// MARK: Save to iCloud
struct PersistenceController {
    static let shared = PersistenceController()

    #if DEBUG
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
                newItem.type = "Movie"
            } else {
                newItem.type = "Book"
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
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    #endif

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
