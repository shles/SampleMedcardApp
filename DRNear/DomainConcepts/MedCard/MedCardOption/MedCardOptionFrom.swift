//
// Created by Артмеий Шлесберг on 03/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

class MedCardOptionFrom: MedCardOption {

    let gradientColors: [UIColor]
    let name: String
    let image: ObservableImage

    private let leadingToController: Transition
    private let transitionSubject = PublishSubject<Transition>()

    init(name: String, image: ObservableImage, gradientColors: [UIColor], leadingTo: Transition) {
        self.name = name
        self.image = image
        self.gradientColors = gradientColors
        self.leadingToController = leadingTo
    }

    func interact() {
        transitionSubject.onNext(leadingToController)
    }

    func wantsToPerform() -> Observable<Transition> {
        return transitionSubject
    }
}

class InactiveMedCardOptionFrom: MedCardOption {

    let gradientColors: [UIColor]
    let name: String
    let image: ObservableImage

    init(name: String, image: ObservableImage, gradientColors: [UIColor]) {
        self.name = name
        self.image = image
        self.gradientColors = gradientColors
    }

    func interact() {

    }

    func wantsToPerform() -> Observable<Transition> {
        return Observable.never()
    }
}
