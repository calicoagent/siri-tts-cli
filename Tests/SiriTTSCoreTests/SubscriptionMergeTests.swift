import XCTest
@testable import SiriTTSCore

final class SubscriptionMergeTests: XCTestCase {
    func testInstallKeepsPreviouslySubscribedVoices() {
        let existing = ["de-DE:natural:undefined:Martin:undefined:0"]
        let merged = SubscriptionMerge.merged(
            adding: "th-TH:neural:undefined:th-TH-B:premium:0",
            to: existing,
            assetKey: { $0 }
        )
        XCTAssertEqual(merged, [
            "de-DE:natural:undefined:Martin:undefined:0",
            "th-TH:neural:undefined:th-TH-B:premium:0",
        ])
    }

    func testReinstallReplacesNormalizedRowInsteadOfDuplicating() {
        let existing = [
            "th-TH:neural:undefined:th-TH-A:undefined:0",
            "de-DE:natural:undefined:Martin:undefined:0",
        ]
        let merged = SubscriptionMerge.merged(
            adding: "th-TH:neural:male:th-TH-A:premium:1089",
            to: existing,
            assetKey: { $0 }
        )
        XCTAssertEqual(merged, [
            "de-DE:natural:undefined:Martin:undefined:0",
            "th-TH:neural:male:th-TH-A:premium:1089",
        ])
    }

    func testIdentityIgnoresGenderFootprintVersionAndCase() {
        XCTAssertEqual(
            SubscriptionMerge.identity(ofAssetKey: "en-US:natural:female:Nora:premium:5068"),
            SubscriptionMerge.identity(ofAssetKey: "en-us:natural:undefined:nora:undefined:0")
        )
    }

    func testDuplicateExistingRowsCollapse() {
        let merged = SubscriptionMerge.merged(
            adding: "ja-JP:neural:male:Hiro:premium:1405",
            to: ["de-DE:a:b:Martin:c:0", "de-DE:x:y:Martin:z:5010"],
            assetKey: { $0 }
        )
        XCTAssertEqual(merged, ["de-DE:a:b:Martin:c:0", "ja-JP:neural:male:Hiro:premium:1405"])
    }
}
