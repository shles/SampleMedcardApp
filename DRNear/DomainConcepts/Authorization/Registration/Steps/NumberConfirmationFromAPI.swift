//
//  NumberConfirmationFromAPI.swift
//  DRNear
//
//  Created by Igor Shmakov on 20/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

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
                    self.transitionSubject.onNext(PushTransition(leadingTo: {
                        ViewController(presentation: PinCodeCreationPresentation(loginApplication: ApplicationSetup(leadingTo: self.leadingTo)))
                    }))
                case .inactive:
                    self.transitionSubject.onNext(PushTransition(leadingTo: {
                        ViewController(presentation: PinCodeCreationPresentation(loginApplication: ApplicationSetup(leadingTo: self.leadingTo)))
                    }))
                case .new:
                    self.transitionSubject.onNext(PushTransition(leadingTo: {
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
