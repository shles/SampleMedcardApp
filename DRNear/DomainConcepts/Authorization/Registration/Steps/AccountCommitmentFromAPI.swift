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
    private let leadingTo: (Token) -> (UIViewController)

    init(leadingTo: @escaping (Token) -> (UIViewController)) {
        self.leadingTo = leadingTo
    }

    func commitAccountInformation(information: AccountInformation) {
//        guard let request = try? UnauthorizedRequest(path: "???",
//                                                     method: .post) else { return }
//        request.make().subscribe({ _ in
//
//            let appSetup = ApplicationSetup()
//
//        } ).disposed(by: disposeBag)

        transitionSubject.onNext(PushTransition(leadingTo: {
            ViewController(presentation: PinCodeCreationPresentation(loginApplication: ApplicationSetup(leadingTo: self.leadingTo)))
        }))
    }

    func wantsToPerform() -> Observable<Transition> {
        return transitionSubject
    }

}
