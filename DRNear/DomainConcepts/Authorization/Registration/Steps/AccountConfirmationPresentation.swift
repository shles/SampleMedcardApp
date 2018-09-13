//
// Created by Артмеий Шлесберг on 27/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit
import UIKit

class AccountConfirmationPresentation: Presentation {
    private(set) var view: UIView = UIView()

    private let supportButton = UIButton()
    private let photo = UIImageView()
    private let confirmButton = GradientButton(colors: [.mainText])
            .with(title: "Продолжить")
            .with(roundedEdges: 24)
    private let transitionSubject = PublishSubject<Transition>()

    //TODO: change to accept full info (photo)
    init(name: String, leadingTo: @escaping () -> (Transition)) {

        let photo = UIImageView()
            .with(image: #imageLiteral(resourceName: "defaultPhoto"))
            .with(roundedEdges: 50)

        let titleLabel = UILabel()
            .with(font: .regular16)
            .with(textColor: .mainText)
            .with(text: "Продолжить как\n\(name)")
            .with(numberOfLines: 2)
            .aligned(by: .center)

        let supportButton = UIButton()
            .with(image: #imageLiteral(resourceName: "callIcon"))

        let supportTitle = UILabel()
            .with(font: .subtitleText13)
            .with(text: "Если у вас возникли вопросы,\nобратитесь в службу поддержки.")
            .with(numberOfLines: 2)
            .with(textColor: .blueGrey)
                .aligned(by: .center)

        let supportStack = UIStackView(arrangedSubviews: [supportTitle, supportButton])
        supportTitle.setContentCompressionResistancePriority(.required, for: .horizontal)
        supportButton.setContentHuggingPriority(.required, for: .horizontal)

        supportStack.distribution = .fill
        supportStack.spacing = 11
        supportStack.axis = .horizontal

        view.addSubviews([photo, titleLabel, confirmButton, supportStack])

        photo.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.snp.centerY).inset(40)
            $0.width.height.equalTo(100)
        }

        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.snp.centerY).offset(40)
        }

        confirmButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(64)
        }

        supportStack.snp.makeConstraints {
            $0.centerX.equalToSuperview()
//            $0.width.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(8)
            $0.height.equalTo(32)
        }

        confirmButton.rx.tap.subscribe(onNext: {
            self.transitionSubject.onNext(leadingTo())
        })
    }

    func willAppear() {

    }

    func wantsToPerform() -> Observable<Transition> {
        return transitionSubject
    }

}
