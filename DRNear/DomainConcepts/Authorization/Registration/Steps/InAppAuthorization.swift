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

    private let leadingTo: () -> (UIViewController)
    private let transitionSubject = PublishSubject<Transition>()
    
    init(leadingTo: @escaping () -> (UIViewController)) {
        self.leadingTo = leadingTo
    }

    let context = LAContext()
    
    func auth(code: String) {

        // TODO: code validation
        proceedToAccount()
    }

    func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func authWithFaceId() {
        
        authWithBiometricID(type: .faceID)
    }
    
    func authWithTouchId() {
        
        authWithBiometricID(type: .touchID)
    }
    
    func authWithBiometricID(type: LABiometryType) {
        
        guard canEvaluatePolicy() else {
            return
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
    
    func proceedToAccount() {
        transitionSubject.onNext(NewWindowRootControllerTransition(leadingTo: { self.leadingTo() }))
    }
    
    func wantsToPerform() -> Observable<Transition> {
        return transitionSubject
    }
}
