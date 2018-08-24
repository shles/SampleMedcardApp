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

    private let leadingToController: () -> (UIViewController)
    private let pushingSubject = ReplaySubject<UIViewController>.create(bufferSize: 1)

    init(name: String, image: ObservableImage, gradientColors: [UIColor], leadingTo: @escaping () -> (UIViewController)) {
        self.name = name
        self.image = image
        self.gradientColors = gradientColors
        self.leadingToController = leadingTo
    }

    func interact() {
        pushingSubject.onNext(leadingToController())
    }

    func wantsToPerform() -> Observable<Transition> {
        return pushingSubject.asObservable().map { vc in PushTransition(leadingTo: { vc }) }
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
