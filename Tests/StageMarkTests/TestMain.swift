import AppKit

@main
struct TestRunner {
    static func main() {
        _ = NSApplication.shared
        NSApp.setActivationPolicy(.accessory)
        NSApp.finishLaunching()
        let suite = CoreTests()
        let integration = IntegrationTests()
        let tests: [(String, () throws -> Void)] = [
            ("line hit testing", suite.testLineHitTestingUsesSegmentsNotBoundingBox),
            ("rectangle edge hit testing", suite.testRectangleOnlyErasesAtBorder),
            ("ellipse edge hit testing", suite.testEllipseOnlyErasesAtBorder),
            ("arrowhead hit testing", suite.testArrowHeadIsErasable),
            ("degenerate stroke", suite.testDegenerateStrokeDoesNotDivideByZero),
            ("constrained shapes", suite.testShiftConstrainedShapesAcrossQuadrants),
            ("undo redo divergent edit", suite.testUndoRedoAndDivergentEdit),
            ("eraser transaction", suite.testEraserDragIsOneUndoableAction),
            ("no-op eraser", suite.testNoOpEraserPreservesUndoHistory),
            ("undo clear", suite.testClearIsUndoableAndEmptyClearDoesNotAddHistory),
            ("bounded history", suite.testHistoryIsBounded),
            ("fade lifecycle", suite.testFadeTimingAndExpiredInkCannotResurrect),
            ("countdown pause resume sleep", suite.testCountdownPauseResumeAndSleep),
            ("countdown formatting", suite.testCountdownRoundingAndHours),
            ("board persistence", suite.testBoardPersistenceRoundTripAndSeparateDisplays),
            ("corrupt board safety", suite.testCorruptBoardFailsWithoutOverwriting),
            ("missing and future board versions", suite.testMissingBoardStartsEmptyAndUnknownVersionFails),
            ("shortcut uniqueness", suite.testDefaultShortcutsAreUniqueAndComplete),
            ("settings persistence and bounds", suite.testPreferencesPersistAndClamp),
            ("settings recovery", suite.testCorruptPreferencesArePreservedForRecovery),
            ("actual rendering for every tool", suite.testAllToolsRenderToRealPixels),
            ("native mouse handlers and text commit", integration.testActualMouseHandlersAndTextCommit),
            ("first stroke after activation", integration.testFirstStrokeAfterActivationReachesInactiveCanvas),
            ("native drawing lifecycle and board isolation", integration.testDrawingLifecycleAndBoardIsolation),
            ("global shortcut registration and release", integration.testShortcutRegistrationAndRelease),
            ("menu bar and non-destructive quick adjustments", integration.testMenuBarAccessAndQuickAdjustmentsPreserveBoard)
        ]
        for (name, test) in tests {
            let before = assertionFailures
            do { try test() } catch { assertionFailures += 1; print("FAIL \(name): \(error)") }
            if assertionFailures == before { print("PASS \(name)") }
        }
        print("\(tests.count) tests · \(assertionCount) assertions · \(assertionFailures) failures")
        exit(assertionFailures == 0 ? 0 : 1)
    }
}
