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

class AccountCommitmentFromAPI: AccountCommitment {

    private let disposeBag = DisposeBag()
    private let transitionSubject = PublishSubject<Transition>()
    private let leadingTo: (Token) -> (UIViewController)
    private let key: String
    
    init(key: String, leadingTo: @escaping (Token) -> (UIViewController)) {
        self.leadingTo = leadingTo
        self.key = key
    }

    func commitAccountInformation(information: AccountInformation) {

        var parameters = information.json
        parameters["key"] = self.key
        
        guard let request = try? UnauthorizedRequest(path: "/eco-uaa/api/register",
                                                     method: .post,

                                                     parameters: parameters,
                encoding: JSONEncoding.default) else { return }
        
        request.make().subscribe(onNext:{ _ in
            
            self.transitionSubject.onNext(PushTransition(leadingTo: {
                ViewController(presentation: PinCodeCreationPresentation(loginApplication: ApplicationSetup(leadingTo: self.leadingTo)))
            }))
            
        }, onError: {
            self.transitionSubject.onNext(ErrorAlertTransition(error: $0))
        }).disposed(by: disposeBag)
    }

    func wantsToPerform() -> Observable<Transition> {
        return transitionSubject
    }

}
