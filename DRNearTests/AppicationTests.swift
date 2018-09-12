//
// Created by Артмеий Шл?есберг on 08/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

@testable import DRNear
import Nimble
import Quick
import RxSwift
import UIKit
import XCTest
//swiftlint:disable all

class ApplicationTests: XCTestCase {
    func testApplication() {
        let configuration = ApplicationConfiguration()
        let view = configuration.rootController().view
        
        view?.layoutSubviews()
        
        XCTAssert(true)
    }
}
//swiftlint:enable all
