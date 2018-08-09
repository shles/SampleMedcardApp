//
// Created by Артмеий Шлесберг on 07/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

@testable import DRNear
import Nimble
import Quick
import RxSwift
import UIKit
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
        describe("simple presentation") {
            it("should present") {
                let presentation = SimpleViewWthButtonPresentation()
                let vc = ViewController(presentation: presentation)
                vc.preloadView()
                var newVC: UIViewController!
                presentation.wantsToPresent().subscribe(onNext: {
                    newVC = $0
                })
                vc.view.subviews.first(where: { $0 is UIButton }).flatMap { $0 as? UIButton }?.sendActions(for: .touchUpInside)

                XCTAssertNil(newVC)
            }
        }
    }
    //swiftlint:enable all
}
