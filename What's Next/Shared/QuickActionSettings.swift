//
//  QuickActionSettings.swift
//  What's Next
//
//  Created by Hundter Biede on 7/13/22.
//

import Foundation
import Observation

/// Where a home screen quick action, widget tap, Spotlight result or App Intent has asked the app to go.
/// `MainScreenView` clears each request once it has handled it, so the same one can be made again.
@MainActor
@Observable
final class QuickActionSettings {
    static let shared = QuickActionSettings()

    nonisolated enum ShortcutAction: String {
        case ADD_REC = "AddRec"
        case SHOW_LIST = "ShowList"
        case GET_REC = "GetRec"
    }

    var quickAction: ShortcutAction?
    /// The type `quickAction` should start on, e.g. books for a tap on a books widget. Set before `quickAction`.
    var requestedType: RecType?
    var recommendationToOpen: UUID?

    private nonisolated static let openRecommendationPrefix = "OpenRec/"

    /// Widget URL that opens a recommendation's detail screen
    nonisolated static func url(opening id: UUID) -> URL? {
        URL(string: openRecommendationPrefix + id.uuidString)
    }

    /// Widget URL that opens `action`'s screen, on `type` if given, e.g. `GetRec/book`
    nonisolated static func url(for action: ShortcutAction, type: RecType? = nil) -> URL? {
        URL(string: [action.rawValue, type?.rawValue].compactMap { $0 }.joined(separator: "/"))
    }

    func handle(_ url: URL) {
        let link = url.absoluteString
        if link.hasPrefix(Self.openRecommendationPrefix) {
            recommendationToOpen = UUID(uuidString: String(link.dropFirst(Self.openRecommendationPrefix.count)))
            return
        }
        let parts = link.split(separator: "/", maxSplits: 1).map(String.init)
        // Ignore links this version doesn't know, rather than guessing at a screen
        guard let action = parts.first.flatMap(ShortcutAction.init(rawValue:)) else { return }
        requestedType = parts.dropFirst().first.flatMap(RecType.init(rawValue:))
        quickAction = action
    }
}
