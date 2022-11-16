//
//  WhatsNextUITests.swift
//  What's NextUITests
//
//  Created by Hundter Biede on 6/22/21.
//  Copyright © 2021 com.hbiede. All rights reserved.
//

import XCTest

let SNAPSHOPPING = false

class WhatsNextUITests: XCTestCase {

    override func setUpWithError() throws {
        super.setUp()
        continueAfterFailure = false
    }

    // swiftlint:disable function_body_length
    func testSnapshots() throws {
        if SNAPSHOPPING {
            UIView.setAnimationsEnabled(false)
        }
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        if SNAPSHOPPING {
            setupSnapshot(app, waitForAnimations: false)
        }
        app.launch()
        app.activate()

        let lang = getLanguage()
        UserDefaults.standard.set(lang, forKey: "i18n_language")
        UserDefaults.standard.set(lang, forKey: "app_lang")

        let bundle = Bundle(path: Bundle(for: type(of: self)).path(forResource: lang, ofType: "lproj")!)!

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        app.buttons[NSLocalizedString("add-menu-button", bundle: bundle, comment: "")].tap()
        let tablesQuery = app.tables

        tablesQuery.cells[
            NSLocalizedString("movie-name-field-label", bundle: bundle, comment: "Movie name edit field label")
        ].textFields[
            NSLocalizedString("movie-name-field-label", bundle: bundle, comment: "Movie name edit field label")
        ].tap()
        app.typeText(
            NSLocalizedString("toy-story-title", bundle: bundle, comment: "Toy Story title")
        )
        tablesQuery.cells[
            NSLocalizedString("rec-by-field-label", bundle: bundle, comment: "Recommended by edit field label")
        ].textFields[
            NSLocalizedString("rec-by-field-label", bundle: bundle, comment: "Recommended by edit field label")
        ].tap()
        app.typeText(
            NSLocalizedString("toy-story-recommender", bundle: bundle, comment: "Who recommender Toy Story")
        )

        tablesQuery.cells[
            NSLocalizedString("notes-field-label", bundle: bundle, comment: "Notes edit field label")
        ].textFields[
            NSLocalizedString("notes-field-label", bundle: bundle, comment: "Notes edit field label")
        ].tap()
        app.typeText(
            NSLocalizedString("toy-story-notes", bundle: bundle, comment: "Toy Story notes")
        )

        if SNAPSHOPPING {
            snapshot("2AddRecommendation")
        }

        XCTAssertTrue(tablesQuery.cells[
            NSLocalizedString("confirm-addition-button-label", bundle: bundle, comment: "")
        ].otherElements.containing(
            .button,
            identifier: NSLocalizedString("confirm-addition-button-label", bundle: bundle, comment: "")
        ).element.isEnabled)
        tablesQuery.cells[
            NSLocalizedString("confirm-addition-button-label", bundle: bundle, comment: "")
        ].otherElements.containing(
            .button,
            identifier: NSLocalizedString("confirm-addition-button-label", bundle: bundle, comment: "")
        ).element.tap()

        XCTAssertTrue(tablesQuery.cells[
            NSLocalizedString("success-saved-message", bundle: bundle, comment: "")
        ].exists)

        app.tables.buttons[NSLocalizedString("tvShow", bundle: bundle, comment: "")].tap()
        XCTAssertTrue(tablesQuery.cells[
            NSLocalizedString("success-saved-message", bundle: bundle, comment: "")
        ].exists)

        tablesQuery.cells[
            NSLocalizedString("tv-show-name-field-label", bundle: bundle, comment: "")
        ].textFields[
            NSLocalizedString("tv-show-name-field-label", bundle: bundle, comment: "")
        ].tap()
        app.typeText(
            NSLocalizedString("breaking-bad-title", bundle: bundle, comment: "Breaking Bad title")
        )
        XCTAssertFalse(tablesQuery.cells[
            NSLocalizedString("success-saved-message", bundle: bundle, comment: "")
        ].exists)
        tablesQuery.cells[
            NSLocalizedString("rec-by-field-label", bundle: bundle, comment: "Recommended by edit field label")
        ].textFields[
            NSLocalizedString("rec-by-field-label", bundle: bundle, comment: "Recommended by edit field label")
        ].tap()
        app.typeText(
            NSLocalizedString("breaking-bad-recommender", bundle: bundle, comment: "Who recommender Breaking Bad")
        )
        tablesQuery.cells[
            NSLocalizedString("confirm-addition-button-label", bundle: bundle, comment: "")
        ].otherElements.containing(
            .button,
            identifier: NSLocalizedString("confirm-addition-button-label", bundle: bundle, comment: "")
        ).element.tap()

        tablesQuery.cells[
            NSLocalizedString("tv-show-name-field-label", bundle: bundle, comment: "")
        ].textFields[
            NSLocalizedString("tv-show-name-field-label", bundle: bundle, comment: "")
        ].tap()
        app.typeText(
            NSLocalizedString("star-trek-title", bundle: bundle, comment: "Star Trek title")
        )
        XCTAssertFalse(
            tablesQuery.cells[NSLocalizedString("success-saved-message", bundle: bundle, comment: "")].exists
        )
        tablesQuery.cells[
            NSLocalizedString("rec-by-field-label", bundle: bundle, comment: "Recommended by edit field label")
        ].textFields[
            NSLocalizedString("rec-by-field-label", bundle: bundle, comment: "Recommended by edit field label")
        ].tap()
        app.typeText(
            NSLocalizedString("star-trek-recommender", bundle: bundle, comment: "Who recommender Star Trek")
        )
        tablesQuery.cells[
            NSLocalizedString("confirm-addition-button-label", bundle: bundle, comment: "")
        ].otherElements.containing(
            .button,
            identifier: NSLocalizedString("confirm-addition-button-label", bundle: bundle, comment: "")
        ).element.tap()

        tablesQuery.cells[
            NSLocalizedString("tv-show-name-field-label", bundle: bundle, comment: "")
        ].textFields[
            NSLocalizedString("tv-show-name-field-label", bundle: bundle, comment: "")
        ].tap()

        app.typeText(
            NSLocalizedString("parks-and-rec-title", bundle: bundle, comment: "Parks and Rec title")
        )
        XCTAssertFalse(tablesQuery.cells[
            NSLocalizedString("success-saved-message", bundle: bundle, comment: "")
        ].exists)
        tablesQuery.cells[
            NSLocalizedString("rec-by-field-label", bundle: bundle, comment: "Recommended by edit field label")
        ].textFields[
            NSLocalizedString("rec-by-field-label", bundle: bundle, comment: "Recommended by edit field label")
        ].tap()
        app.typeText(
            NSLocalizedString("parks-and-rec-recommender", bundle: bundle, comment: "Who recommender Parks and Rec")
        )
        tablesQuery.cells[
            NSLocalizedString("confirm-addition-button-label", bundle: bundle, comment: "")
        ].otherElements.containing(
            .button,
            identifier: NSLocalizedString("confirm-addition-button-label", bundle: bundle, comment: "")
        ).element.tap()

        app.navigationBars[
            NSLocalizedString("add-rec-screen-title", bundle: bundle, comment: "")
        ].buttons.firstMatch.tap()
        if SNAPSHOPPING {
            snapshot("4MainMenu")
        }

        app.buttons[NSLocalizedString("whats-next-menu-button", bundle: bundle, comment: "")].tap()
        XCTAssertTrue(tablesQuery.staticTexts[
            NSLocalizedString("toy-story-recommender", bundle: bundle, comment: "Who recommender Toy Story")
        ].exists)
        XCTAssertFalse(
            tablesQuery
                .cells[NSLocalizedString("refresh-button-label", bundle: bundle, comment: "")]
                .otherElements
                .containing(
                    .button,
                    identifier: NSLocalizedString("refresh-button-label", bundle: bundle, comment: "")
                )
                .element
                .exists
        )

        app.tables.buttons[NSLocalizedString("tvShow", bundle: bundle, comment: "Who recommender Toy Story")].tap()
        XCTAssertTrue(
            tablesQuery.staticTexts[
                NSLocalizedString("breaking-bad-recommender", bundle: bundle, comment: "Who recommender Breaking Bad")
            ].exists ||
            tablesQuery.staticTexts[
                NSLocalizedString("star-trek-recommender", bundle: bundle, comment: "Who recommender Star Trek")
            ].exists ||
            tablesQuery.staticTexts[
                NSLocalizedString("parks-and-rec-recommender", bundle: bundle, comment: "Who recommender Parks and Rec")
            ].exists
        )
        XCTAssertTrue(
            tablesQuery
                .cells[NSLocalizedString("refresh-button-label", bundle: bundle, comment: "")]
                .otherElements
                .containing(
                    .button,
                    identifier: NSLocalizedString("refresh-button-label", bundle: bundle, comment: "")
                )
                .element
                .exists
        )
        if SNAPSHOPPING {
            snapshot("1Recommendation")
        }

        app.navigationBars[
            NSLocalizedString("up-next-page-title", bundle: bundle, comment: "")
        ].buttons.firstMatch.tap()
        app.buttons[
            NSLocalizedString("see-list-menu-button", bundle: bundle, comment: "")
        ].tap()
        if SNAPSHOPPING {
            snapshot("3List")
        }

        // Clear entries
        tablesQuery.buttons.firstMatch.tap()
        tablesQuery.buttons[NSLocalizedString("delete-recommnedation-button", bundle: bundle, comment: "")].tap()
        tablesQuery.buttons.firstMatch.tap()
        tablesQuery.buttons[NSLocalizedString("delete-recommnedation-button", bundle: bundle, comment: "")].tap()
        tablesQuery.buttons.firstMatch.tap()
        tablesQuery.buttons[NSLocalizedString("delete-recommnedation-button", bundle: bundle, comment: "")].tap()
        tablesQuery.buttons.firstMatch.tap()
        tablesQuery.buttons[NSLocalizedString("delete-recommnedation-button", bundle: bundle, comment: "")].tap()
    }
    // swiftlint:enable function_body_length

    // Uncomment when not using as a snapshot scheme
    func testLaunchPerformance() throws {
        if !SNAPSHOPPING {
            if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
                // This measures how long it takes to launch your application.
                measure(metrics: [XCTApplicationLaunchMetric()]) {
                    XCUIApplication().launch()
                }
            }
        }
    }

    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}
