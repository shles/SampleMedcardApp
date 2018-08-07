//
// Created by Артмеий Шлесберг on 07/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import UIKit
import Quick
import Nimble
import RxSwift
@testable import DRNear
//swiftlint:disable all
class SimpleObjectsTests: QuickSpec {
    override func spec() {
        describe("Simple presentation") {
            let presentation = SimpleViewWthButtonPresentation()
            context("when button tapped") {
                it("should wants to present") {
                    var vc: UIViewController?
                    presentation.wantsToPresent().subscribe(onNext: {
                        vc = $0
                    })
                    presentation.simulateButtonTap()
                    expect(vc != nil).to(be(true))
                }
            }
        }
        describe("Simple bad habit") {
            let badHabit = SimpleBadHabit()
            context("when selected") {
                it("should become deselected") {
                    badHabit.select()

                    expect(try! badHabit.isSelected.toBlocking().first()!).to(be(false))
                }
            }
        }
    }
    //swiftlint:enable all
}
