//
//  InAppAuthorization.swift
//  DRNear
//
//  Created by Igor Shmakov on 20/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import LocalAuthentication

class InAppAuthorization: Authorization {

    private let leadingTo: (Token) -> (UIViewController)
    private let transitionSubject = PublishSubject<Transition>()
    
    init(leadingTo: @escaping (Token) -> (UIViewController)) {
        self.leadingTo = leadingTo
    }

    private let context = LAContext()
    
    func auth(code: String) {

        if let savedCode = ApplicationConfiguration().code {
            if savedCode == code {
                proceedToAccount()
            } else {
                transitionSubject.onNext(ErrorAlertTransition(error: RequestError(message: "Неверный пинкод. Попробуйте еще раз")))
            }
        } else {
            transitionSubject.onNext(NewWindowRootControllerTransition(leadingTo: { UINavigationController(
                    rootViewController: ViewController(
                            presentation: NumberRegistrationPresentation(
                                    numberRegistration: NumberRegistrationFromAPI(leadingTo: self.leadingTo )
                            )
                    )
            ).withoutNavigationBar()}))
        }
    }

    private func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    private func proceedToAccount() {
        if let token = ApplicationConfiguration().token {
            transitionSubject.onNext(NewWindowRootControllerTransition(leadingTo: { self.leadingTo(TokenFromString(string: token)) }))
        } else {
            transitionSubject.onNext(NewWindowRootControllerTransition(leadingTo: { UINavigationController(
                    rootViewController: ViewController(
                            presentation: NumberRegistrationPresentation(
                                    numberRegistration: NumberRegistrationFromAPI(leadingTo: self.leadingTo )
                            )
                    )
            ).withoutNavigationBar()}))
        }
    }
    
    func wantsToPerform() -> Observable<Transition> {
        return transitionSubject
    }

    func tryToAuthWithBiometry() {
        guard canEvaluatePolicy() else {
            return
        }

        var type: LABiometryType

        if UserDefaults.standard.bool(forKey: "touchIDKey") {
            type = .touchID
        } else if UserDefaults.standard.bool(forKey: "faceIDKey"){
            type = .faceID
        } else  {
            type = .none
        }

        let reason = "Используйте \(type == .touchID ? "Touch ID" : "Face ID") чтобы выйти в приложение"

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, evaluateError in
            if success {
                DispatchQueue.main.async {
                    self.proceedToAccount()
                }
            }
        }
    }
}
