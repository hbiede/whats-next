//
//  AppIntentsTests.swift
//  What's NextUITests
//
//  Created by Hundter Biede on 10/9/26.
//  Copyright © 2026 com.hbiede. All rights reserved.
//

import AppIntentsTesting
import XCTest

/// Runs the app's App Intents out of process, the way Siri and Shortcuts do
@available(iOS 27.0, *)
final class AppIntentsTests: XCTestCase {
    private let definitions = IntentDefinitions(bundleIdentifier: "com.hbiede.WhatsNext")
    /// Every recommendation these tests add starts with this, so `tearDown` can remove them all
    private let testPrefix = "AppIntentsTests-"

    override func setUp() async throws {
        // The system only registers the app's intents once it has launched
        await MainActor.run { XCUIApplication().launch() }
    }

    override func tearDown() async throws {
        try await definitions.intents["RemoveTestRecommendationsIntent"].makeIntent(namePrefix: testPrefix).run()
    }

    func testAddRecommendation() async throws {
        let name = testPrefix + UUID().uuidString
        let result = try await definitions.intents["ShortcutIntent"].makeIntent(
            recommendationType: "book",
            author: "Ursula K. Le Guin",
            name: name,
            recommender: "Keiko"
        ).run()

        let addedName: String = try result.value.name
        let addedAuthor: String = try result.value.author
        XCTAssertEqual(addedName, name)
        XCTAssertEqual(addedAuthor, "Ursula K. Le Guin")

        let matches = try await definitions.entities["RecommendationEntity"].entities(matching: name)
        XCTAssertEqual(matches.count, 1)
    }

    func testWhatsNextPicksTheRequestedType() async throws {
        try await definitions.intents["ShortcutIntent"].makeIntent(
            recommendationType: "tvShow",
            name: testPrefix + UUID().uuidString
        ).run()

        let result = try await definitions.intents["GetNextRecommendationIntent"].makeIntent(
            recommendationType: "tvShow"
        ).run()

        let type: AnyAppEnum = try result.value.type
        XCTAssertEqual(type.rawValue, "tvShow")
    }
}
