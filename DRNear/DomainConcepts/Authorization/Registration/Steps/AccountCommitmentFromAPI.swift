//
//  AccountCommitmentFromAPI.swift
//  DRNear
//
//  Created by Igor Shmakov on 20/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

class AccountCommitmentFromAPI: AccountCommitment {
    
    private let disposeBag = DisposeBag()
    private let transitionSubject = PublishSubject<Transition>()

    init() {
    
    }
    
    func commitAccountInformation(information: AccountInformation) {
//        guard let request = try? UnauthorizedRequest(path: "???",
//                                                     method: .post) else { return }
//        request.make().subscribe({ _ in
//
//            let appSetup = ApplicationSetup()
//
//        } ).disposed(by: disposeBag)

        let appSetup = ApplicationSetup()
        transitionSubject.onNext(PushTransition(leadingTo: {
            ViewController(presentation: PincСdeCreationPresentation(loginApplication: ApplicationSetup()))
        }))
    }
    
    func wantsToPerform() -> Observable<Transition> {
        return transitionSubject
    }
    
}
