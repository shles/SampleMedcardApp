//
// Created by Артмеий Шлесберг on 24/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import RxSwift
import UIKit

class PincodeConfirmationPresentation: Presentation {

    private(set) var view: UIView

    private let accountCommitment: AccountCommitment

    init(accountCommitment: AccountCommitment) {
        self.accountCommitment = loginApplication
        view = EnterCodeView(
                title: "Повторите пинкод",
                image: #imageLiteral(resourceName: "page1Copy"),
                symbolsNumber: 6)

        (view as? EnterCodeView)?.codeEntered.subscribe(onNext: { [unowned self] in
            self.accountCommitment.confirmPincode(code: $0)
        })
    }
    func willAppear() {

    }

    func wantsToPerform() -> Observable<Transition> {
        return loginApplication.wantsToPerform()
    }

}

class PinCodeCreationPresentation: Presentation {
    private(set) var view: UIView

    private let transitionsSubject = PublishSubject<Transition>()
    private let accountCommitment: AccountCommitment

    init(accountCommitment: AccountCommitment) {
        self.accountCommitment = accountCommitment

        view = EnterCodeView(
                title: "Придумайте пинкод",
                image: #imageLiteral(resourceName: "page1Copy"),
                symbolsNumber: 6)

        (view as? EnterCodeView)?.codeEntered.subscribe(onNext: { [unowned self] in
            self.accountCommitment.createPincode(code: $0)
        })
    }

    func willAppear() {
    }

    func wantsToPerform() -> Observable<Transition> {
        return accountCommitment.wantsToPerform()
    }
}
