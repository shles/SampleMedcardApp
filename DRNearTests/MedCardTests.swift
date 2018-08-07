//
// Created by Артмеий Шлесберг on 06/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import XCTest
import Quick
import Nimble
import RxBlocking
import RxSwift

@testable import DRNear
//swiftlint:disable all
class MedCardTests: QuickSpec {

    override func spec() {
        
        var viewController: UIViewController!
        var option: MedCardOption!
        var medCard: MedCard!
        var medCardPresentation: Presentation!
        var disposeBag: DisposeBag!

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
        }

        describe("MedCard presentation") {
            context("when one of it's options interacted") {
                it("should want push view") {

                    var vc: UIViewController!
                    
                    medCardPresentation.wantsToPush().subscribe(onNext: {
                        vc = $0
                    })
                    option.interact()
                    expect(vc).to(equal(viewController))
                }
            }
        }
    }
}

//swiftlint:enable all
