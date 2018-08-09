//
// Created by Артмеий Шл?есберг on 08/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

@testable import DRNear
import Nimble
import Quick
import RxSwift
import UIKit
//swiftlint:disable all

class ApplicationTests: QuickSpec {
    override func spec() {
        describe("Application") {
            let nav = UIApplication.shared.keyWindow?.rootViewController as! UINavigationController

            context("on login screen with admin") {
                let loginVC = nav.visibleViewController!
                it("should leads to medcard screen") {
                    let tfs = loginVC.view.subviews[0].subviews
                        .first(where: { $0 is UIStackView })
                        .flatMap { $0 as? UIStackView }?
                        .arrangedSubviews
                        .filter { $0 is UITextField }
                        .flatMap { $0 as? UITextField }
                    tfs![0].text = "admin"
                    tfs![1].text = "38Gjgeuftd!"

                    loginVC.view.subviews[0].subviews
                            .first(where: { $0 is UIStackView })
                            .flatMap { $0 as? UIStackView }?
                            .arrangedSubviews.first(where: { $0 is UIButton })
                            .flatMap { $0 as? UIButton }?
                            .sendActions(for: .touchUpInside)

                    if let vc = try? (loginVC as? ViewController)?.presentation.wantsToPush().toBlocking(timeout:10).first(),
                        let presentation = (vc as? ViewController)?.presentation {

                        vc?.view.subviews
                            .first(where: { $0 is UICollectionView })
                            .flatMap { $0 as? UICollectionView }?
                            .selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .top)

                        XCTAssertNil(try? presentation.wantsToPresent().toBlocking(timeout: 5).first())
                    }

                    XCTAssertNil(try? (loginVC as? ViewController)?.presentation.wantsToPush().toBlocking(timeout:5).first())
                }
            }
            context("on login with user") {
                nav.popToRootViewController(animated: false)
                let loginVC = nav.visibleViewController!
                it("should leads to confirm screen") {
                    let tfs = loginVC.view.subviews[0].subviews
                        .first(where: { $0 is UIStackView })
                        .flatMap { $0 as? UIStackView }?
                        .arrangedSubviews
                        .filter { $0 is UITextField }
                        .flatMap { $0 as? UITextField }
                    tfs![0].text = "user"
                    tfs![1].text = "SiblionBest!!"
                    
                    loginVC.view.subviews[0].subviews
                        .first(where: { $0 is UIStackView })
                        .flatMap { $0 as? UIStackView }?
                        .arrangedSubviews.first(where: { $0 is UIButton })
                        .flatMap { $0 as? UIButton }?
                        .sendActions(for: .touchUpInside)
                    }
                
                    let vc = try? (loginVC as? ViewController)?.presentation.wantsToPush().toBlocking(timeout:5).first()
                    vc??.preloadView()
                
                    XCTAssertNil(vc)
                
            }

        }

    }
}
//swiftlint:enable all
