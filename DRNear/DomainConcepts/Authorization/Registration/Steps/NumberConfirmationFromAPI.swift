//
//  NumberConfirmationFromAPI.swift
//  DRNear
//
//  Created by Igor Shmakov on 20/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

class NumberConfirmationFromAPI: NumberConfirmation {
    
    private let disposeBag = DisposeBag()
    private var number: String

    private let transitionSubject = PublishSubject<Transition>()


    init(number: String) {
        self.number = number
    }
    
    func confirmNumber(code: String) {
//        guard let request = try? UnauthorizedRequest(path: "???",
//                                                     method: .post,
//                                                     parameters: ["number": self.number,
//                                                                  "code": code]) else { return }
//        request.make().subscribe({ _ in
           
            /*
            if alreadyRegisterd {
                let appSetup = ApplicationSetup()
            } else {
                let commitmentStep = AccountCommitmentFromAPI()
            }
            */
            
//            let commitmentStep = AccountCommitmentFromAPI()
//
//        } ).disposed(by: disposeBag)

        let commitmentStep = AccountCommitmentFromAPI()
        transitionSubject.onNext(PushTransition(leadingTo: {
            ViewController(presentation: AccountCreationPresentation(
                    commitment: AccountCommitmentFromAPI()))
        }))
    }

    func wantsToPerform() -> Observable<Transition> {
        return transitionSubject
    }
    
}
