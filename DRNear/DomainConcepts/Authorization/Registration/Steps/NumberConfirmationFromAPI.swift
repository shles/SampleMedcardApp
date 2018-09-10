//
//  NumberConfirmationFromAPI.swift
//  DRNear
//
//  Created by Igor Shmakov on 20/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON
import LocalAuthentication
import JWTDecode

enum UserStatus: String {
    
    case new = "NEW"
    case inactive = "INACTIVE"
    case active = "ACTIVE"
}

class NumberConfirmationFromAPI: NumberConfirmation {

    private let disposeBag = DisposeBag()
    private var number: String

    private let transitionSubject = PublishSubject<Transition>()

    private let leadingTo: (Token) -> (UIViewController)

    init(number: String, leadingTo: @escaping (Token) -> (UIViewController)) {
        self.leadingTo = leadingTo
        self.number = number
    }

    func confirmNumber(code: String) {
        
        let number = self.number.hasPrefix("+7") ? String(self.number.dropFirst(2)) : self.number
        
        guard let request = try? UnauthorizedRequest(path: "/eco-uaa/api/code/check",
                                                     method: .get,
                                                     parameters: [
                                                        "phone": number,
                                                        "code": code]) else { return }
        
        request.make().subscribe(onNext:{ response in
            
            if let status = UserStatus(rawValue: response["status"].string ?? ""),
                let key = response["key"].string {
                
                switch status {
                case .active:
                    //todo: make different presentation for enter existing pin
                    self.transitionSubject.onNext(PushTransition(leadingTo: { [unowned self] in
                        ViewController(presentation: ExistingPinEnterPresentation(auth: AuthorizationFromAPI(number: self.number, key: key, leadingTo: self.leadingTo, name: response["assumption"].string ?? "существующий пользователь")))
                    }))

                case .inactive:
                    self.transitionSubject.onNext(PushTransition(leadingTo: { [unowned self] in
                        ViewController(presentation: PinCodeCreationPresentation(accountCommitment: AccountCommitmentFromAPI(key: key, number: self.number, leadingTo: self.leadingTo)))
                    }))

                case .new:
                    self.transitionSubject.onNext(PushTransition(leadingTo: { [unowned self] in
                        ViewController(presentation: AccountCreationPresentation(
                            commitment: AccountCommitmentFromAPI(key: key, number: self.number, leadingTo: self.leadingTo)))
                    }))
                }
            } else {
                self.transitionSubject.onNext(ErrorAlertTransition(error: ResponseError()))
            }
            
        }, onError: {
            self.transitionSubject.onNext(ErrorAlertTransition(error: $0))
        }).disposed(by: disposeBag)
    }

    func wantsToPerform() -> Observable<Transition> {
        return transitionSubject
    }

}

class ExistingPinEnterPresentation: Presentation {
    private(set) var view: UIView

    private let disposeBag = DisposeBag()

    private let auth: AuthorizationFromAPI

    init(auth: AuthorizationFromAPI) {
        self.auth = auth
        view = EnterCodeView(
                title: "Введите свой пинкод",
                image: #imageLiteral(resourceName: "page1Copy"),
                symbolsNumber: 4)

        (view as? EnterCodeView)?.codeEntered.subscribe(onNext: { [unowned self] in
            self.auth.auth(code: $0)
        }).disposed(by: disposeBag)
    }
    func willAppear() {

    }

    func wantsToPerform() -> Observable<Transition> {
        return auth.wantsToPerform()
    }

}


class AuthorizationFromAPI: Authorization {

    private var transitionSubject = PublishSubject<Transition>()

    private let number: String
    private let key: String
    private var code: String = ""
    private let disposeBag = DisposeBag()
    private let name: String
    private let leadingTo: (Token) -> (UIViewController)

    private var request: UnauthorizedRequest!

    init(number: String, key: String, leadingTo: @escaping (Token) -> (UIViewController), name: String) {
        self.number = number
        self.key = key
        self.leadingTo = leadingTo
        self.name = name
    }

    func auth(code: String) {
        self.code = code

        let parameters =  [
            "key": key,
            "password": code,
            "username": number
        ]

        guard let request = try? UnauthorizedRequest(path: "/auth/login",
                method: .post,

                parameters: parameters,
                encoding: JSONEncoding.default) else {
            return
        }

        self.request = request

        request.make().do(onError: { _ in
                    let cookieStore = HTTPCookieStorage.shared
                    if let cookie = cookieStore.cookies?.first(where: { $0.name == "XSRF-TOKEN" }), cookie.value != UserDefaults.standard.string(forKey: "X-XSRF-TOKEN") {
                        for cookie in cookieStore.cookies ?? [] {
                            cookieStore.deleteCookie(cookie)
                        }
                        UserDefaults.standard.set(nil, forKey: "X-XSRF-TOKEN")
                    }
                }).retry(3).subscribe(onNext: { json in

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
            if let refreshToken = json["refresh_token"].string {
                ApplicationConfiguration().saveRefreshToken(token: refreshToken)
            }
        }, onError: {
            self.transitionSubject.onNext(ErrorAlertTransition(error: $0))
        }).disposed(by: disposeBag)
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
                            }, onCancel: { [unowned self] in
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
                            }, onCancel: { [unowned self] in
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
                                    name: self.name,
                                    leadingTo: { [unowned self] in
                                        NewWindowRootControllerTransition(leadingTo: { self.leadingTo(token) })
                                    }))}))

    }

    func tryToAuthWithBiometry() {

    }
}


