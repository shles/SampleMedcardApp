//
// Created by Артмеий Шлесберг on 07/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SnapKit

class SimpleLoginPresentation: Presentation {

    var view: UIView = UIView()
    private var button = UIButton()
        .with(title: "Войти")
        .with(backgroundColor: .black)
    private var loginField = UITextField()
        .with(placeholder: "Login")
    private var passwordField = UITextField()
            .with(placeholder: "Password")

    private let authority: Authority
    private let disposeBag = DisposeBag()
    private let leadingTo: (Token)->(UIViewController)

    init(authority: Authority, leadingTo: @escaping (Token)->(UIViewController)) {
        self.authority = authority
        self.leadingTo = leadingTo

        let label = UILabel()
            .with(numberOfLines: 0)
            .with(text: "To login as admin, use 'admin' and any password. To login as user, use any credentials")
            .with(textColor: .lightGray)

        let stack = UIStackView(arrangedSubviews: [loginField, passwordField, button, label])

        stack.spacing = 16
        stack.alignment = .fill
        stack.axis = .vertical

        loginField.borderStyle = .roundedRect
        passwordField.borderStyle = .roundedRect

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
    }

    func wantsToPush() -> Observable<UIViewController> {
        return Observable<UIViewController>.merge([
                authority.wantsTFAuth().map {
                    ViewController(presentation: SimpleCodeConfirmationPresentation(authority: $0, leadingTo: self.leadingTo))
                },
                authority.authenticated().map { [unowned self] in
                    self.leadingTo($0)
                }
            ]
        )
    }

    func wantsToPresent() -> Observable<UIViewController> {
        return Observable.never()
    }

    func wantsToPop() -> Observable<Void> {
        return Observable.never()
    }

    func wantsToBeDismissed() -> Observable<Void> {
        return Observable.never()
    }

    func willAppear() {
        loginField.becomeFirstResponder()
    }
}
