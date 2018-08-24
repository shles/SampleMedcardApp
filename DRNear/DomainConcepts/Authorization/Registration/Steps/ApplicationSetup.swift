//
//  ApplicationSetup.swift
//  DRNear
//
//  Created by Igor Shmakov on 20/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

class ApplicationSetup: LoginMethodsApplication {

    private let transitionSubject = PublishSubject<Transition>()

    init() {
        
    }
    
    func createPincode(code: String) {
        transitionSubject.onNext(PushTransition {
            ViewController(presentation: PincodeConfirmationPresentation(loginApplication: self))
        })
    }
    
    func confirmPincode(code: String) {
        
    }
    
    func activateTouchID() {
        
    }
    
    func activateFaceID() {
        
    }
    
    func proceedToAccount() {
        
    }

    func wantsToPerform() -> Observable<Transition> {
        return transitionSubject
    }
}
