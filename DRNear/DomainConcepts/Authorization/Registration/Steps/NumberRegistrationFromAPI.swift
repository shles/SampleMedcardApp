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

        //создаешь запрос

        guard let request = try? UnauthorizedRequest(path: "???",
                                                     method: .post,
                                                     parameters: ["number": number]) else { return }

        //Вызываешь запрос.
        //Метод возвращает Observable. На него подписываешь .subscribe(onNext: {}, onError: {} ).
        //onNext {} параметр - реакция на удачный резултат выполнения запросв
        //onError {} параметр - реакция на ошибку
        //transitionSubject - это Observer. В него можно посылать события.
        //.onNext(Transition) вызовет в нем событие с этим транзишн.
        request.make().subscribe(onNext:{ _ in

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
