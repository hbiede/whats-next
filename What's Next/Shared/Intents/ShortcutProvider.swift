//
//  ShortcutProvider.swift
//  What's Next
//
//  Created by Hundter Biede on 11/16/22.
//  Copyright © 2022 com.hbiede. All rights reserved.
//

import AppIntents
import Foundation

@available(iOS 16.0, *)
struct WhatsNextAppShortcuts: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .purple

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ShortcutIntent(),
            phrases: [
                "Add Recommendation in \(.applicationName)",
            ],
            systemImageName: "popcorn.fill"
        )
    }
}
