//
// Created by Артмеий Шлесберг on 24/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import RxSwift
import SnapKit
import UIKit

class ConfirmNumberPresentation: Presentation {

    private var numberConfirmation: NumberConfirmation
    private var enterCodeView: EnterCodeView

    init(confirmation: NumberConfirmation) {

        enterCodeView = EnterCodeView(
                title: "Для проверки номера телефона, введите код из СМС",
                image: #imageLiteral(resourceName: "page1Copy"),
                symbolsNumber: 6)
        self.numberConfirmation = confirmation

        view.addSubview(enterCodeView)

        enterCodeView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        enterCodeView.codeEntered.subscribe(onNext: { [unowned self] in
            self.numberConfirmation.confirmNumber(code: $0)
        })

    }

    private(set) var view: UIView = UIView()

    func willAppear() {

    }

    func wantsToPerform() -> Observable<Transition> {
        return numberConfirmation.wantsToPerform()
    }
}
