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
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    // swiftlint:disable function_body_length
    func testSnapshots() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments += ["testing"]
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        app.buttons["Add"].tap()
        let tablesQuery = app.tables

        tablesQuery.cells["Movie name"].textFields["Movie name"].tap()
        app.typeText("Toy Story 3")
        tablesQuery.cells["Recommended by"].textFields["Recommended by"].tap()
        app.typeText("Keiko")

        tablesQuery.cells["Notes"].textFields["Notes"].tap()
        app.typeText("Emotional 🥲")

        snapshot("2AddRecommendation")

        XCTAssertTrue(tablesQuery.cells["Add"].otherElements.containing(.button, identifier: "Add").element.isEnabled)
        tablesQuery.cells["Add"].otherElements.containing(.button, identifier: "Add").element.tap()

        XCTAssertTrue(tablesQuery.cells["Saved"].exists)

        app.tables.buttons["TV Show"].tap()
        XCTAssertTrue(tablesQuery.cells["Saved"].exists)

        tablesQuery.cells["TV show name"].textFields["TV show name"].tap()
        app.typeText("Breaking Bad")
        XCTAssertFalse(tablesQuery.cells["Saved"].exists)
        print(tablesQuery.cells["Add"].otherElements.containing(.button, identifier: "Add").element.isEnabled)
        tablesQuery.cells["Recommended by"].textFields["Recommended by"].tap()
        app.typeText("Adam")
        tablesQuery.cells["Add"].otherElements.containing(.button, identifier: "Add").element.tap()

        tablesQuery.cells["TV show name"].textFields["TV show name"].tap()
        app.typeText("Star Trek: TNG")
        XCTAssertFalse(tablesQuery.cells["Saved"].exists)
        print(tablesQuery.cells["Add"].otherElements.containing(.button, identifier: "Add").element.isEnabled)
        tablesQuery.cells["Recommended by"].textFields["Recommended by"].tap()
        app.typeText("Elijah")
        tablesQuery.cells["Add"].otherElements.containing(.button, identifier: "Add").element.tap()

        tablesQuery.cells["TV show name"].textFields["TV show name"].tap()

        app.typeText("Parks and Rec")
        XCTAssertFalse(tablesQuery.cells["Saved"].exists)
        print(tablesQuery.cells["Add"].otherElements.containing(.button, identifier: "Add").element.isEnabled)
        tablesQuery.cells["Recommended by"].textFields["Recommended by"].tap()
        app.typeText("Alex")
        tablesQuery.cells["Add"].otherElements.containing(.button, identifier: "Add").element.tap()

        app.navigationBars["Add Recommendation"].buttons["Back"].tap()
        snapshot("4MainMenu")

        app.buttons["See What\'s Next"].tap()
        XCTAssertTrue(tablesQuery.staticTexts["Keiko"].exists)
        XCTAssertFalse(
            tablesQuery
                .cells["Refresh"]
                .otherElements
                .containing(.button, identifier: "Refresh")
                .element
                .exists
        )

        app.tables.buttons["TV Show"].tap()
        XCTAssertTrue(
            tablesQuery.staticTexts["Adam"].exists ||
            tablesQuery.staticTexts["Elijah"].exists ||
            tablesQuery.staticTexts["Alex"].exists
        )
        XCTAssertTrue(
            tablesQuery
                .cells["Refresh"]
                .otherElements
                .containing(.button, identifier: "Refresh")
                .element
                .exists
        )
        snapshot("1Recommendation")

        app.navigationBars["Up Next"].buttons["Back"].tap()
        app.buttons["See List"].tap()
        snapshot("3List")

        // Clear entries
        tablesQuery.buttons["Toy Story 3, Movie, Recommended by: Keiko, June 24, 2021"].tap()
        tablesQuery.buttons["Delete"].tap()
        tablesQuery.buttons["Breaking Bad, TV Show, Recommended by: Adam, September 14, 2019"].tap()
        tablesQuery.buttons["Delete"].tap()
        tablesQuery.buttons["Star Trek: TNG, TV Show, Recommended by: Elijah, May 29, 2020"].tap()
        tablesQuery.buttons["Delete"].tap()
        tablesQuery.buttons["Parks and Rec, TV Show, Recommended by: Alex, October 17, 2020"].tap()
        tablesQuery.buttons["Delete"].tap()
    }
    // swiftlint:enable function_body_length

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
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
