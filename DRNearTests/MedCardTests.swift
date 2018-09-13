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

        let transition = PresentTransition(leadingTo: { ViewController(presentation: SimpleViewWthButtonPresentation()) })
        let option = MedCardOptionFrom(
            name: "test",
            image: ObservableImageFrom(UIImage()),
            gradientColors: [.white],
            leadingTo: transition
        )
        let medcardPresentationSpy = MedCardCollectionViewPresentationSpy(
            medCardOptions: MedCardFrom(
                    options: [option]
                )
            )
        let disposeBag = DisposeBag()
        it("should lead to presentation") {
            let replaySubject = ReplaySubject<Transition>.create(bufferSize: 1)
            var trans: Transition!
            medcardPresentationSpy.wantsToPerform()
                .subscribe(onNext: {
                    replaySubject.onNext($0)
                    trans = $0
                })
                .disposed(by: disposeBag)
//            medcardPresentationSpy.selectOption(at: IndexPath(row: 0, section: 0))
            option.interact()

            XCTAssertNotNil(try! replaySubject.toBlocking(timeout: 5).first())

        }

    }

}

//swiftlint:enable all
