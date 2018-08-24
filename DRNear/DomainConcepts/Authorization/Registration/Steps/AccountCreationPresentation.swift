//
// Created by Артмеий Шлесберг on 24/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

class AccountCreationPresentation: Presentation {

    private var photo = UIImageView()
    .with(image: #imageLiteral(resourceName: "chatIcon"))
    .with(roundedEdges: 50)

    private var surnameLabel = UITextField()
    .with(font: .medium13)
    .with(placeholderFont: .subtitleText13)
    .with(texColor: .mainText)
    .with(placeholderColor: .shadow)
    .with(placeholder: "Фамилия")
    private var nameLabel = UITextField()
    .with(font: .medium13)
    .with(placeholderFont: .subtitleText13)
    .with(texColor: .mainText)
    .with(placeholderColor: .shadow)
    .with(placeholder: "Имя")
    private var secondNameLabel = UITextField()
    .with(font: .medium13)
    .with(placeholderFont: .subtitleText13)
    .with(texColor: .mainText)
    .with(placeholderColor: .shadow)
    .with(placeholder: "Отчество")
    private var birthDateLabel = UITextField()
    .with(font: .medium13)
    .with(placeholderFont: .subtitleText13)
    .with(texColor: .mainText)
    .with(placeholderColor: .shadow)
    .with(placeholder: "Дата рождения")
    private var emailLabel = UITextField()
    .with(font: .medium13)
    .with(placeholderFont: .subtitleText13)
    .with(texColor: .mainText)
    .with(placeholderColor: .shadow)
    .with(placeholder: "E-Mail")

    private var genderView = UIView()
    private var confirmButton = UIButton()
            .with(title: "Продолжить")
            .with(backgroundColor: .mainText)
            .with(roundedEdges: 24)

    private let navBar: SimpleNavigationBar

    private var commitment: AccountCommitment

    init(commitment: AccountCommitment) {

        self.commitment = commitment

        navBar = SimpleNavigationBar(title: "Регистрация")

        let stack = UIStackView(
                arrangedSubviews: [surnameLabel, nameLabel, secondNameLabel, birthDateLabel, genderView, emailLabel].map {
                    FieldContainer(view: $0)
                }
        )

        stack.axis = .vertical

        let scrollView = TPKeyboardAvoidingScrollView()

//        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)

        scrollView.addSubviews([photo, stack])
        view.addSubviews([navBar, scrollView, confirmButton])

        photo.snp.makeConstraints {
            $0.centerX.equalTo(stack)
            $0.top.equalTo(navBar.snp.bottom).offset(16)
            $0.width.height.equalTo(100)
        }

        stack.snp.makeConstraints {
            $0.top.equalTo(photo.snp.bottom).offset(64)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.width.equalTo(view)

        }

        scrollView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.top.equalTo(navBar.snp.bottom)
        }

        navBar.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(120)
        }

        confirmButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
        }

        confirmButton.rx.tap.subscribe(onNext: {
            commitment.commitAccountInformation(information: AccountInformationFrom())
        })
    }

    private(set) var view: UIView = UIView()

    func willAppear() {

    }

    func wantsToPerform() -> Observable<Transition> {
        return  commitment.wantsToPerform()
    }
}
