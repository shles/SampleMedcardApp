//
// Created by Артмеий Шлесберг on 07/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit
import UIKit

class SimpleLoginPresentation: Presentation {

    var view: UIView = UIView()
    private var button = UIButton()
        .with(title: "Войти")
        .with(backgroundColor: .black)
    private var loginField: UITextField
    private var passwordField = UITextField()
            .with(placeholder: "Password")

    private let authority: Authority
    private let disposeBag = DisposeBag()
    private let leadingTo: (Token) -> (UIViewController)

    init(authority: Authority, leadingTo: @escaping (Token) -> (UIViewController)) {
        self.authority = authority
        self.leadingTo = leadingTo

        loginField = UITextField()
            .with(placeholder: "Login")
            .with(next: passwordField, disposeBag: disposeBag)
        .with(resignOn: [.editingDidEnd, .editingDidEndOnExit], disposeBag: disposeBag)

        let label = UILabel()
            .with(numberOfLines: 0)
            .with(text: "To login as admin, use 'admin' and password '38Gjgeuftd!'. To login as user, use login 'user' and password 'SiblionBest!'")
            .with(textColor: .lightGray)

        let stack = UIStackView(arrangedSubviews: [loginField, passwordField, button, label])

        stack.spacing = 16
        stack.alignment = .fill
        stack.axis = .vertical

        loginField.borderStyle = .roundedRect
        passwordField.borderStyle = .roundedRect
        passwordField.autocorrectionType = .no
        loginField.autocorrectionType = .no
        loginField.autocapitalizationType = .none
        passwordField.autocapitalizationType = .none
        view.backgroundColor = .white
        view.addSubview(stack)

        stack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(200)
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.equalToSuperview().inset(40)

        }

        button.rx.tap
        .map { [unowned self] in
            CredentialsFrom(login: self.loginField.text ?? "", password: self.passwordField.text ?? "")
        }
        .subscribe(onNext: { [unowned self] in
            self.authority.authWith(credentials: $0)
        })
        .disposed(by: disposeBag)

        button.rx.controlEvent(.touchDown).subscribe(onNext: { [unowned self] in
            self.button.backgroundColor = self.button.backgroundColor?.withAlphaComponent(0.5)
            self.button.titleLabel?.alpha = 0.8
        }).disposed(by: disposeBag)

        button.rx.controlEvent([.touchCancel, .touchUpOutside, .touchUpInside]).subscribe(onNext: { [unowned self] in
            self.button.backgroundColor = self.button.backgroundColor?.withAlphaComponent(1)
            self.button.titleLabel?.alpha = 1
        }).disposed(by: disposeBag)
    }

    func willAppear() {
        loginField.becomeFirstResponder()
    }

    func wantsToPerform() -> Observable<Transition> {
        return Observable<Transition>.merge([
            authority.wantsTFAuth().map { [unowned self] authority in
                PushTransition(leadingTo: {
                    ViewController(presentation: SimpleCodeConfirmationPresentation(authority: authority, leadingTo: self.leadingTo))
                })
            },
            authority.authenticate().map { [unowned self]  token in
                NewWindowRootControllerTransition(leadingTo: { self.leadingTo(token) })
            }
        ])
    }
}
