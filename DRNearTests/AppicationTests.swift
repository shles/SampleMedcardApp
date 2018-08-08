//
// Created by Артмеий Шл?есберг on 08/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import UIKit
import RxSwift
import Quick
import Nimble
@testable import DRNear
//swiftlint:disable all

class ApplicationTests: QuickSpec {
    override func spec() {
        describe("Application") {
            let nav = UIApplication.shared.keyWindow?.rootViewController as! UINavigationController
            
            context("on login screen with empty fields") {
                it("should leads to confirm screen") {

                    nav.visibleViewController?.view.subviews[0].subviews
                            .first(where: { $0 is UIStackView})
                            .flatMap {$0 as? UIStackView}?
                            .arrangedSubviews.first(where: {$0 is UIButton})
                            .flatMap { $0 as? UIButton}?
                            .sendActions(for: .touchUpInside)

                    expect((nav.visibleViewController as! ViewController).presentation is SimpleCodeConfirmationPresentation).to(be(true))

                }
                
//                nav.visibleViewController?.loadView()
//                nav.visibleViewController?.preloadView()
//
//                it("should leads to medcard screen") {
//                    nav.visibleViewController?.view.subviews[0].subviews
//                        .first(where: { $0 is UIStackView})
//                        .flatMap {$0 as? UIStackView}?
//                        .arrangedSubviews.first(where: {$0 is UIButton})
//                        .flatMap { $0 as? UIButton}?
//                        .sendActions(for: .touchUpInside)
//
//                    expect((nav.visibleViewController as! ViewController).presentation is MedCardCollectionViewPresentation).to(be(true))
//                }
            }
            
        }

    }
}
//swiftlint:enable all

