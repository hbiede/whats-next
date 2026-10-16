//
//  WhatsNextUITests.swift
//  What's NextUITests
//
//  Created by Hundter Biede on 6/22/21.
//  Copyright © 2021 com.hbiede. All rights reserved.
//

import XCTest

class WhatsNextUITests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }

    // swiftlint:disable function_body_length
    @MainActor
    func testSnapshots() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        setupSnapshot(app, waitForAnimations: false)
        // Start from an empty store every run; fastlane's setupSnapshot adds this too
        if !app.launchArguments.contains("-ui_testing") {
            app.launchArguments.append("-ui_testing")
        }
        app.launch()

        let bundle = Self.localizedBundle(for: getLanguage())
        let string = { (keyName: String) in NSLocalizedString(keyName, bundle: bundle, comment: "") }
        // Forms and Lists, which SwiftUI builds from collection views
        let form = app.collectionViews.firstMatch
        let savedMessage = form.staticTexts[string("success-saved-message")]

        // MARK: Add Recommendations
        app.buttons[string("add-menu-button")].tap()

        type(string("toy-story-title"), into: form.textFields[string("movie-name-field-label")])
        type(string("toy-story-recommender"), into: form.textFields[string("rec-by-field-label")])
        type(string("toy-story-notes"), into: form.textFields[string("notes-field-label")])

        snapshot("2AddRecommendation")

        // Put the keyboard away so it can't cover the Add button
        app.typeText("\n")
        let addButton = form.buttons[string("confirm-addition-button-label")]
        XCTAssertTrue(addButton.isEnabled)
        addButton.tap()
        XCTAssertTrue(savedMessage.waitForExistence(timeout: 2))

        form.buttons[string("tvShow")].tap()
        XCTAssertTrue(savedMessage.exists)

        for show in ["breaking-bad", "star-trek", "parks-and-rec"] {
            type(string("\(show)-title"), into: form.textFields[string("tv-show-name-field-label")])
            XCTAssertFalse(savedMessage.exists)
            type(string("\(show)-recommender") + "\n", into: form.textFields[string("rec-by-field-label")])
            addButton.tap()
            XCTAssertTrue(savedMessage.waitForExistence(timeout: 2))
        }

        goBack(in: app)
        snapshot("4MainMenu")

        // MARK: See What's Next
        app.buttons[string("whats-next-menu-button")].tap()
        let refreshButton = form.buttons[string("refresh-button-label")]
        XCTAssertTrue(form.staticTexts[string("toy-story-recommender")].waitForExistence(timeout: 2))
        XCTAssertFalse(refreshButton.exists)

        form.buttons[string("tvShow")].tap()
        XCTAssertTrue(
            ["breaking-bad", "star-trek", "parks-and-rec"].contains {
                form.staticTexts[string("\($0)-recommender")].exists
            }
        )
        XCTAssertTrue(refreshButton.exists)
        snapshot("1Recommendation")

        // MARK: See List
        goBack(in: app)
        app.buttons[string("see-list-menu-button")].tap()
        XCTAssertTrue(form.waitForExistence(timeout: 2))
        snapshot("3List")

        // Clear entries
        for _ in 0..<4 {
            form.buttons.firstMatch.tap()
            form.buttons[string("delete-recommnedation-button")].tap()
        }
        XCTAssertFalse(form.buttons.firstMatch.waitForExistence(timeout: 2))
    }
    // swiftlint:enable function_body_length

    // Skipped in the Snapshots scheme
    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    /// iOS 27 moved the system back button out of the navigation bar into its own toolbar,
    /// so find it by UIKit's identifier instead of through the bar
    @MainActor
    private func goBack(in app: XCUIApplication) {
        app.buttons["BackButton"].firstMatch.tap()
    }

    @MainActor
    private func type(_ text: String, into field: XCUIElement) {
        field.tap()
        field.typeText(text)
    }

    /// The test bundle's strings in the language the app is running in. fastlane passes languages like "es-MX",
    /// which `preferredLocalizations` maps to the bundle's "es.lproj"; outside fastlane it's empty.
    private static func localizedBundle(for language: String) -> Bundle {
        let testBundle = Bundle(for: WhatsNextUITests.self)
        let localization = Bundle.preferredLocalizations(
            from: testBundle.localizations,
            forPreferences: language.isEmpty ? nil : [language]
        ).first
        return localization
            .flatMap { testBundle.path(forResource: $0, ofType: "lproj") }
            .flatMap(Bundle.init(path:)) ?? testBundle
    }
}
