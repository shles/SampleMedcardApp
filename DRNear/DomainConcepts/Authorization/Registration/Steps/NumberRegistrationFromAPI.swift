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

//        guard let request = try? UnauthorizedRequest(path: "???",
//                                                     method: .post,
//                                                     parameters: ["number": number]) else { return }
//        request.make().subscribe({ _ in
//
//            let numberConfirmation = NumberConfirmationFromAPI(number: number)
//
//        }).disposed(by: disposeBag)

        transitionSubject.onNext(PushTransition(leadingTo: { [unowned self] in
            ViewController(presentation: ConfirmNumberPresentation(
                    confirmation: NumberConfirmationFromAPI(number: number,leadingTo: self.leadingTo)))
        }))
    }
    
    func wantsToPerform() -> Observable<Transition> {
        return transitionSubject
    }
    
}
