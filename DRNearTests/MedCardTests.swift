//
// Created by Артмеий Шлесберг on 06/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
import RxBlocking
import RxSwift
import XCTest

@testable import DRNear
//swiftlint:disable all
class MedCardTests: QuickSpec {

    override func spec() {

        var viewController: UIViewController!
        var option: MedCardOption!
        var medCard: MedCard!
        var medCardPresentation: Presentation!
        var disposeBag: DisposeBag!
        var medCArdViewcontroller: UIViewController!

        beforeEach {
            viewController = UIViewController()
            option = MedCardOptionFrom(
                    name: "Test",
                    image: EmptyObservableImage(),
                    gradientColors: [],
                    leadingTo: viewController
            )
            medCard = MedCardFrom(options: [option])
            medCardPresentation = MedCardCollectionViewPresentation(medCardOptions: medCard)
            disposeBag = DisposeBag()
            medCArdViewcontroller = ViewController(presentation: medCardPresentation)
        }

        describe("MedCard presentation") {
            context("when one of it's options interacted") {
                it("should want push view") {

                    var vc: UIViewController!

                    medCardPresentation.wantsToPush().subscribe(onNext: {
                        vc = $0

                        UIApplication.shared.keyWindow!.rootViewController = vc
                        vc.preloadView()

                    }).disposed(by: disposeBag)
                    UIApplication.shared.keyWindow!.rootViewController = medCArdViewcontroller

                    medCArdViewcontroller.preloadView()
                    option.interact()
                    expect(vc.view) == viewController.view
                }
            }
        }
    }
}

//swiftlint:enable all
