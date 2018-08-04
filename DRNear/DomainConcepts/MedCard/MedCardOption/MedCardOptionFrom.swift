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

    private let leadingToController: UIViewController
    private let pushingSubject = ReplaySubject<UIViewController>.create(bufferSize: 1)

    init(name: String, image: ObservableImage, gradientColors: [UIColor], leadingTo: UIViewController) {
        self.name = name
        self.image = image
        self.gradientColors = gradientColors
        self.leadingToController = leadingTo
    }

    func wantsToPush() -> Observable<UIViewController> {
        return pushingSubject.asObservable()
    }

    func wantsToPresent() -> Observable<UIViewController> {
        return Observable.never()
    }

    func interact() {
        pushingSubject.onNext(leadingToController)
    }

    func wantsToPop() -> Observable<Void> {
        return Observable.never()
    }

    func wantsToBeDismissed() -> Observable<Void> {
        return Observable.never()
    }

}