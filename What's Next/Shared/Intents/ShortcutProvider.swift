//
//  ShortcutProvider.swift
//  What's Next
//
//  Created by Hundter Biede on 11/16/22.
//  Copyright © 2022 com.hbiede. All rights reserved.
//

import AppIntents
import Foundation

struct WhatsNextAppShortcuts: AppShortcutsProvider {
    static let shortcutTileColor: ShortcutTileColor = .purple

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetNextRecommendationIntent(),
            phrases: [
                "What should I try next in \(.applicationName)",
                "What \(\.$recommendationType) should I try next in \(.applicationName)",
                "Get a recommendation from \(.applicationName)"
            ],
            shortTitle: "get-rec-title",
            systemImageName: "lightbulb.fill"
        )
        AppShortcut(
            intent: ShortcutIntent(),
            phrases: [
                "Add Recommendation in \(.applicationName)",
            ],
            shortTitle: "Add Recommendation",
            systemImageName: "popcorn.fill"
        )
    }
}
