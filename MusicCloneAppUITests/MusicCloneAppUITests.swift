import XCTest

final class MusicCloneAppUITests: XCTestCase {
    @MainActor func testOfflineHomeSearchLibraryFlow() throws {
        let app = XCUIApplication(); app.launch()
        app.buttons["Try offline demo"].tap()
        XCTAssertTrue(app.buttons["Save Night Windows"].waitForExistence(timeout: 5))
        app.buttons["Save Night Windows"].tap()
        app.tabBars.buttons["Library"].tap()
        XCTAssertTrue(app.buttons["Preview Night Windows"].exists)
        app.tabBars.buttons["Search"].tap()
        app.textFields["albumSearch"].tap(); app.textFields["albumSearch"].typeText("Mara")
        XCTAssertTrue(app.buttons["Preview Low Tide"].waitForExistence(timeout: 5))
        app.buttons["Preview Low Tide"].tap()
        XCTAssertTrue(app.buttons["Pause preview"].exists)
    }
}
