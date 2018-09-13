//
//  NumberRegistrationFromAPI.swift
//  DRNear
//
//  Created by Igor Shmakov on 20/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

class NumberRegistrationFromAPI: NumberRegistration {

    private let disposeBag = DisposeBag()
    private let transitionSubject = PublishSubject<Transition>()

    private let leadingTo: (Token) -> (UIViewController)

    init(leadingTo: @escaping (Token) -> (UIViewController)) {
        self.leadingTo = leadingTo
    }

    func register(number: String) {

        let number = number.hasPrefix("+7") ? String(number.dropFirst(2)) : number

        guard let request = try? UnauthorizedRequest(path: "/eco-uaa/api/code/send",
                                                     method: .get,
                                                     parameters: ["phone": number]) else { return }

        request.make().subscribe(onNext: { _ in

            let numberConfirmation = NumberConfirmationFromAPI(number: number, leadingTo: self.leadingTo)

            self.transitionSubject.onNext(PushTransition(leadingTo: { [unowned self] in
                ViewController(presentation: ConfirmNumberPresentation(
                        confirmation: numberConfirmation))
            }))

        }, onError: {
            self.transitionSubject.onNext(ErrorAlertTransition(error: $0))
        }).disposed(by: disposeBag)
    }

    func wantsToPerform() -> Observable<Transition> {
        return transitionSubject
    }
}
