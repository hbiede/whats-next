//
//  WhatsNextApp.swift
//  Shared
//
//  Created by Hundter Biede on 6/17/21.
//

import AppIntents
import SwiftUI


@main
struct WhatsNextApp: App {
    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif
    let persistenceController = PersistenceController.shared

    init() {
        // Keep UI tests' throwaway data out of the widgets and Spotlight
        if !PersistenceController.isUITesting {
            RecommendationSync.shared.start()
        }
    }

    var body: some Scene {
        WindowGroup {
            MainScreenView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(QuickActionSettings.shared)
        }
    }
}

#if os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        IntentDonationManager.shared.donate(intent: ShortcutIntent())

        if let shortcutItem = options.shortcutItem,
           let newShortcutAction = QuickActionSettings.ShortcutAction(rawValue: shortcutItem.type) {
            QuickActionSettings.shared.quickAction = newShortcutAction
        }

        let sceneConfiguration = UISceneConfiguration(name: "Custom Configuration", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = CustomSceneDelegate.self

        return sceneConfiguration
    }
}

class CustomSceneDelegate: UIResponder, UIWindowSceneDelegate {
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        let newShortcutAction = QuickActionSettings.ShortcutAction(rawValue: shortcutItem.type)
        if let newShortcutAction {
            QuickActionSettings.shared.quickAction = newShortcutAction
        }
        completionHandler(newShortcutAction != nil)
    }
}
#endif
