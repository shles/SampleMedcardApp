//
// Created by Артмеий Шлесберг on 30/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

class AuthorizationPresentation: Presentation {

    private var auth: Authorization
    private var enterCodeView: EnterCodeView

    init(auth: Authorization) {
        self.auth = auth

        enterCodeView = EnterCodeView(
                title: "Введите пинкод",
                image: #imageLiteral(resourceName: "page1Copy"),
                symbolsNumber: 4)

        view.addSubview(enterCodeView)

        enterCodeView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        enterCodeView.codeEntered.subscribe(onNext: { [unowned self] in
            self.auth.auth(code: $0)
        })
    }

    func willAppear() {
        auth.tryToAuthWithBiometry()
    }

    private(set) var view: UIView = UIView()

    func wantsToPerform() -> Observable<Transition> {
        return auth.wantsToPerform()
    }
}