//
// Created by Артмеий Шлесберг on 02/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import UIKit
import RxSwift

protocol MedCardOption: Named, TransitionSource, ContainingImage, Interactive {

    var gradientColors: [UIColor] { get }

}

class SimpleMedCardOption: MedCardOption {
    private(set) var gradientColors: [UIColor] = [.red, .yellow]
    private(set) var name: String = "Вредные привычки"

    private let leadingToController = ViewController(presentation: SimpleViewWthButtonPresentation())
    private let pushingSubject = ReplaySubject<UIViewController>.create(bufferSize: 1)

    func wantsToPush() -> Observable<UIViewController> {
        return pushingSubject.asObservable().debug()
    }

    func wantsToPresent() -> Observable<UIViewController> {
        return Observable.never()
    }

    var image: ObservableImage {
       return SimpleObservableImage()
    }

    func interact() {
        pushingSubject.onNext(leadingToController)
    }
}

