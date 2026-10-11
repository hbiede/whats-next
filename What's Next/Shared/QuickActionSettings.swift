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
    var recommendationToOpen: UUID?

    private nonisolated static let openRecommendationPrefix = "OpenRec/"

    /// Widget URL that opens a recommendation's detail screen
    nonisolated static func url(opening id: UUID) -> URL? {
        URL(string: openRecommendationPrefix + id.uuidString)
    }

    func handle(_ url: URL) {
        let link = url.absoluteString
        if link.hasPrefix(Self.openRecommendationPrefix),
           let id = UUID(uuidString: String(link.dropFirst(Self.openRecommendationPrefix.count))) {
            recommendationToOpen = id
        } else {
            quickAction = link == ShortcutAction.ADD_REC.rawValue ? .ADD_REC : .GET_REC
        }
    }
}
