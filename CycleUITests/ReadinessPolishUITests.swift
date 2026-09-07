import XCTest

final class ReadinessPolishUITests: XCTestCase {
    func testSettingsShowsPrivacyAndEstimateGuidance() {
        let app = XCUIApplication()
        app.launch()

        let getStarted = app.buttons["Get Started"]
        if getStarted.waitForExistence(timeout: 5) {
            let onboardingScrollView = app.scrollViews.firstMatch
            XCTAssertTrue(onboardingScrollView.waitForExistence(timeout: 5))
            onboardingScrollView.swipeUp()
            XCTAssertTrue(getStarted.isHittable)

            let onboardingAttachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
            onboardingAttachment.name = "Onboarding with reachable Get Started"
            onboardingAttachment.lifetime = .keepAlways
            add(onboardingAttachment)
            getStarted.tap()
        }

        let settingsButton = app.buttons["Settings"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()

        let privacyHeader = app.staticTexts.matching(
            NSPredicate(format: "label == %@", "Privacy & Estimates")
        ).firstMatch
        for _ in 0..<5 where !privacyHeader.exists {
            app.collectionViews.firstMatch.swipeUp()
        }
        XCTAssertTrue(privacyHeader.waitForExistence(timeout: 5))

        let privacyCopy = app.staticTexts.matching(
            NSPredicate(format: "label BEGINSWITH %@", "Cycle data is stored on this device.")
        ).firstMatch
        let estimateCopy = app.staticTexts.matching(
            NSPredicate(format: "label BEGINSWITH %@", "Period timing and fertile-window estimates use averages")
        ).firstMatch
        for _ in 0..<3 where !privacyCopy.isHittable || !estimateCopy.isHittable {
            app.collectionViews.firstMatch.swipeUp()
        }
        XCTAssertTrue(privacyCopy.isHittable)
        XCTAssertTrue(estimateCopy.isHittable)

        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Settings privacy and estimates"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
