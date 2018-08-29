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
import LocalAuthentication
import JWTDecode
import SwiftyJSON

//TODO: needed to be refactored. split into appropriate separate steps objects

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

        //TODO: have to be refactored. should be fork somewhere before, to split
        if self.code == code {

            if let information = information {
                var parameters = information.json

                parameters["key"] = self.key
                parameters["phoneNumber"] = self.number
                parameters["pin"] = code

                guard let request = try? UnauthorizedRequest(path: "/eco-uaa/api/register",
                        method: .post,

                        parameters: parameters,
                        encoding: JSONEncoding.default) else {
                    return
                }

                request.make().subscribe(onNext: { [unowned self] json in

                    if let token = json["access_token"].string {
                        let jwt = try? decode(jwt: token)
                        if let authorities = jwt?.body["authorities"] as? [String] {
                            if let _ = authorities.first(where: { $0 == "ROLE_USER" }) {
                                self.configureLoginMethods(token: TokenFromString(string: token))
                            } else {
                                //TODO: actually I don't know what to do here yet
                                self.transitionSubject.onNext(ErrorAlertTransition(error: ResponseError()))
                            }
                        }
                    } else {
                        self.transitionSubject.onNext(ErrorAlertTransition(error: ResponseError.from(json: json) ?? ResponseError()))
                    }
                    if let refreshToken = json["access_token"].string {
                        ApplicationConfiguration().saveRefreshToken(token: refreshToken)
                    }
                }, onError: {
                    self.transitionSubject.onNext(ErrorAlertTransition(error: $0))
                }).disposed(by: disposeBag)
            } else {

                let parameters =  [
                    "key": key,
                    "newPin": code,
                    "phoneNumber": number
                ]

                guard let request = try? UnauthorizedRequest(path: "/eco-uaa/api/account/reset-password",
                        method: .put,

                        parameters: parameters,
                        encoding: JSONEncoding.default) else {
                    return
                }

                request.make().subscribe(onNext: { [unowned self] json in

                    if let token = json["access_token"].string {
                        let jwt = try? decode(jwt: token)
                        if let authorities = jwt?.body["authorities"] as? [String] {
                            if let _ = authorities.first(where: { $0 == "ROLE_USER" }) {
                                self.configureLoginMethods(token: TokenFromString(string: token))
                            } else {
                                //TODO: actually I don't know what to do here yet
                                self.transitionSubject.onNext(ErrorAlertTransition(error: ResponseError()))
                            }
                        }
                    } else {
                        self.transitionSubject.onNext(ErrorAlertTransition(error: ResponseError.from(json: json) ?? ResponseError()))
                    }
                    if let refreshToken = json["access_token"].string {
                        ApplicationConfiguration().saveRefreshToken(token: refreshToken)
                    }
                }, onError: {
                    self.transitionSubject.onNext(ErrorAlertTransition(error: $0))
                }).disposed(by: disposeBag)


            }

            } else {
                transitionSubject.onNext(ErrorAlertTransition(error: RequestError(message: "Pin-код не совпадает, повторите попытку")))
            }

    }

    func proceedToAccount(token: Token) {
//        let authority = AuthorityFromAPI()
//        authority.authenticate().retry(10).map { [unowned self] token in
//        }.bind(to: transitionSubject)
//        authority.authWith(credentials: CredentialsFrom(login: "admin", password: "38Gjgeuftd!"))
        ApplicationConfiguration().saveCode(code: code)
        transitionSubject.onNext(PushTransition(
                leadingTo: { [unowned self] in
                    ViewController(
                        presentation: AccountConfirmationPresentation(
                                name: self.information.name,
                                leadingTo: { [unowned self] in
            NewWindowRootControllerTransition(leadingTo: { self.leadingTo(token) })
        }))}))

    }

    func wantsToPerform() -> Observable<Transition> {
        return transitionSubject
    }

    func configureLoginMethods(token: Token) {
        let context = LAContext()

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            switch context.biometryType {
            case .touchID:
                self.transitionSubject.onNext( PresentTransition {
                    ViewController(presentation: BiometricIDPresentation(
                            title: "Использовать Touch ID для приложения “Доктор Рядом Телемед”?",
                            type: .touchID,
                            onAccept: { [unowned self] in
                                self.activateTouchID()
                                self.proceedToAccount(token: token)
                            }))
                })
            case .faceID:
                self.transitionSubject.onNext( PresentTransition {
                    ViewController(presentation: BiometricIDPresentation(
                            title: "Использовать Face ID для приложения “Доктор Рядом Телемед”?",
                            type: .faceID,
                            onAccept: { [unowned self] in
                                self.activateFaceID()
                                self.proceedToAccount(token: token)
                            }))
                })
            case .none:
                proceedToAccount(token: token)
            }
        } else {
            proceedToAccount(token: token)
        }
    }

    func activateTouchID() {
        //TODO: make injection
        ApplicationConfiguration().activateTouchID(forCode: self.code)

    }

    func activateFaceID() {
        ApplicationConfiguration().activateFaceID(forCode: self.code)
    }

}
