//
//  AccountCommitmentFromAPI.swift
//  DRNear
//
//  Created by Igor Shmakov on 20/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

//TODO: needed to be refactored. split into appropriate separate steps abjects

class AccountCommitmentFromAPI: AccountCommitment {

    private let disposeBag = DisposeBag()
    private let transitionSubject = PublishSubject<Transition>()
    private let leadingTo: (Token) -> (UIViewController)
    private let key: String
    private let number: String
    private var code: String = ""

    private var information: AccountInformation!

    init(key: String, number: String, leadingTo: @escaping (Token) -> (UIViewController)) {
        self.leadingTo = leadingTo
        self.key = key
        self.number = number
    }

    func commitAccountInformation(information: AccountInformation) {

//        var parameters = information.json
//
//        parameters["key"] = self.key
//        parameters["phoneNumber"] = self.number
//
//        guard let request = try? UnauthorizedRequest(path: "/eco-uaa/api/register",
//                                                     method: .post,
//
//                                                     parameters: parameters,
//                encoding: JSONEncoding.default) else { return }
//
//        request.make().subscribe(onNext:{ _ in
//
//        }, onError: {
//            self.transitionSubject.onNext(ErrorAlertTransition(error: $0))
//        }).disposed(by: disposeBag)

        self.information = information

        self.transitionSubject.onNext(PushTransition(leadingTo: {
            ViewController(presentation: PinCodeCreationPresentation(accountCommitment: self))
        }))
    }

    func createPincode(code: String) {
        self.code = code
        transitionSubject.onNext(PushTransition { [unowned self] in
            return ViewController(presentation: PincodeConfirmationPresentation(accountCommitment: self))
        })
    }

    func confirmPincode(code: String) {
        if self.code == code {

            var parameters = information.json

            parameters["key"] = self.key
            parameters["phoneNumber"] = self.number

            guard let request = try? UnauthorizedRequest(path: "/eco-uaa/api/register",
                    method: .post,

                    parameters: parameters,
                    encoding: JSONEncoding.default) else { return }

            request.make().subscribe(onNext:{ _ in
                transitionSubject.onNext( PresentTransition {
                    ViewController(presentation: TouchIDPresentation(
                            title: "Использовать Touch ID для приложения “Доктор Рядом Телемед”?",
                            onAccept: { [unowned self] in
                                self.activateTouchID()
                                self.proceedToAccount()
                            }))
                })
            }, onError: {
                self.transitionSubject.onNext(ErrorAlertTransition(error: $0))
            }).disposed(by: disposeBag)

        } else {
            transitionSubject.onNext(ErrorAlertTransition(error: RequestError(message: "Pin-код не совпадает, повторите попытку")))
        }
    }

    func wantsToPerform() -> Observable<Transition> {
        return transitionSubject
    }

}
