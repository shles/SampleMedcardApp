//
//  DeletionPresentationTests.swift
//  DRNearTests
//
//  Created by Артмеий Шлесберг on 11/09/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import XCTest
import RxSwift

@testable import DRNear
class DeletionTest: XCTestCase {
    func testClose() {
        var testValue = 0
        let deletionPresentation = DeletionPresentationSpy(title: "", onAccept: {
            testValue = 1
            return Observable.just(())
        })
        let view = deletionPresentation.view
        view.layoutSubviews()
        deletionPresentation.tapAccept()
        
        XCTAssertEqual(testValue, 1)
    }
}

class AdditionalInfoTest: XCTestCase {
    func testAddingInfo() {
        var testValue: String!
        let infoPresentation = CommentPresentationSpy(title: "", gradient: [], onAccept: {
            testValue = $0
            })
        let view = infoPresentation.view
        view.layoutSubviews()
        infoPresentation.addComment(string: "111")
        XCTAssertEqual("111", testValue)
    }
}
