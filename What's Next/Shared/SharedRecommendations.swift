//
//  SharedRecommendations.swift
//  What's Next
//
//  Created by Hundter Biede on 10/9/26.
//  Copyright © 2026 com.hbiede. All rights reserved.
//

import Foundation

/// A recommendation as the widgets see it. The app copies every recommendation into the App Group whenever its data
/// changes (see `RecommendationSync`), so the widget extension never has to open the Core Data store.
nonisolated struct WidgetRecommendation: Codable, Hashable, Identifiable, Sendable {
    let id: UUID
    let name: String
    let type: RecType
    let author: String?
    let recommender: String?
    let recommendationDate: Date?
}

nonisolated enum SharedRecommendations {
    private struct Pick: Codable {
        let id: UUID
        let chosenOn: Date
    }

    private static var defaults: UserDefaults? { UserDefaults(suiteName: APP_GROUP) }

    // MARK: Recommendations
    /// Every recommendation, oldest first, or `nil` if the app hasn't written them since it was updated
    static func load() -> [WidgetRecommendation]? {
        guard let data = defaults?.data(forKey: RECOMMENDATIONS_KEY) else { return nil }
        return try? JSONDecoder().decode([WidgetRecommendation].self, from: data)
    }

    /// Returns whether anything changed, so callers only reload widgets when they need to
    @discardableResult
    static func save(_ recommendations: [WidgetRecommendation]) -> Bool {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        guard let defaults, let data = try? encoder.encode(recommendations) else { return false }
        defaults.removeObject(forKey: WIDGET_COUNT_KEY)
        guard defaults.data(forKey: RECOMMENDATIONS_KEY) != data else { return false }
        defaults.set(data, forKey: RECOMMENDATIONS_KEY)
        return true
    }

    static func counts() -> [RecType: Int] {
        guard let recommendations = load() else { return legacyCounts() }
        return recommendations.reduce(into: [:]) { counts, recommendation in
            counts[recommendation.type, default: 0] += 1
        }
    }

    /// Counts saved by version 1.4 and earlier, so widgets aren't empty between updating and next opening the app
    private static func legacyCounts() -> [RecType: Int] {
        guard
            let data = defaults?.data(forKey: WIDGET_COUNT_KEY),
            let countsDict = try? NSKeyedUnarchiver.unarchivedObject(
                ofClasses: [NSDictionary.self, NSString.self, NSNumber.self],
                from: data
            ) as? [String: Int]
        else { return [:] }
        return countsDict.reduce(into: [:]) { counts, entry in
            if let type = RecType(rawValue: entry.key) {
                counts[type] = entry.value
            }
        }
    }

    // MARK: Up Next Widget Picks
    /// The recommendation the Up Next widget shows for `type`. It stays the same for the rest of the day, unless
    /// it's shuffled or removed.
    static func pick(
        for type: RecType,
        in recommendations: [WidgetRecommendation],
        date: Date = .now
    ) -> WidgetRecommendation? {
        let candidates = recommendations.filter { $0.type == type }
        var picks = loadPicks()
        if let pick = picks[type.rawValue],
           Calendar.current.isDate(pick.chosenOn, inSameDayAs: date),
           let current = candidates.first(where: { $0.id == pick.id }) {
            return current
        }
        guard let chosen = candidates.randomElement() else { return nil }
        picks[type.rawValue] = Pick(id: chosen.id, chosenOn: date)
        savePicks(picks)
        return chosen
    }

    /// Picks a different recommendation of `type`, if there is one
    static func shuffle(_ type: RecType) {
        let candidates = (load() ?? []).filter { $0.type == type }
        var picks = loadPicks()
        let others = candidates.filter { $0.id != picks[type.rawValue]?.id }
        guard let chosen = (others.isEmpty ? candidates : others).randomElement() else { return }
        picks[type.rawValue] = Pick(id: chosen.id, chosenOn: .now)
        savePicks(picks)
    }

    private static func loadPicks() -> [String: Pick] {
        guard let data = defaults?.data(forKey: WIDGET_PICKS_KEY) else { return [:] }
        return (try? JSONDecoder().decode([String: Pick].self, from: data)) ?? [:]
    }

    private static func savePicks(_ picks: [String: Pick]) {
        defaults?.set(try? JSONEncoder().encode(picks), forKey: WIDGET_PICKS_KEY)
    }
}
