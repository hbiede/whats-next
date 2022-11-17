//
//  WhatsNextApp.swift
//  Shared
//
//  Created by Hundter Biede on 6/17/21.
//

import AppIntents
import SwiftUI

let quickActionSettings = QuickActionSettings()

@main
struct WhatsNextApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainScreenView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(quickActionSettings)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        if #available(iOS 16.0, *) {
            IntentDonationManager.shared.donate(intent: ShortcutIntent())
        }

        if let shortcutItem = options.shortcutItem {
            print("Shortcut")
            print(shortcutItem)
            if let newShortcutAction = QuickActionSettings.ShortcutAction(rawValue: shortcutItem.type) {
                quickActionSettings.quickAction = newShortcutAction
            }
        }
        
        let sceneConfiguration = UISceneConfiguration(name: "Custom Configuration", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = CustomSceneDelegate.self
        
        return sceneConfiguration
    }
}

class CustomSceneDelegate: UIResponder, UIWindowSceneDelegate {
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if let newShortcutAction = QuickActionSettings.ShortcutAction(rawValue: shortcutItem.type) {
            quickActionSettings.quickAction = newShortcutAction
        }
    }
}
