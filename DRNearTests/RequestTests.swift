//
//  RequestTests.swift
//  DRNearTests
//
//  Created by Артмеий Шлесберг on 11/09/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import XCTest
@testable import DRNear
import RxSwift
import RxBlocking
import SwiftyJSON

//swiftlint:disable all
class RequestTest: XCTestCase {
    
    func testAuthRequest() {
        let req = try! AuthorizedRequest(path: "/fail", token: TokenFromString(string: ""))
        XCTAssertNotNil(try? req.make().catchErrorJustReturn(JSON(arrayLiteral: [])).toBlocking().first())
    }
    
    func testUnauthRequest() {
        let req = try! UnauthorizedRequest(path: "/fail")
        XCTAssertNotNil(try? req.make().catchErrorJustReturn(JSON(arrayLiteral: [])).toBlocking().first())
    }
    
    
}
//swiftlint:anable all
