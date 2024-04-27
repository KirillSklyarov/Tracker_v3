//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Kirill Sklyarov on 26.04.2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testViewController() {
        let vc = TrackerViewController(viewModel: TrackerViewModel())

        assertSnapshots(matching: vc, as: [.image])

    }
}
