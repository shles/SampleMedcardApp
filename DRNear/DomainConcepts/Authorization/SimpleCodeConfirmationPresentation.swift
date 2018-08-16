//
// Created by Артмеий Шлесберг on 07/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import RxSwift
import UIKit

class SimpleCodeConfirmationPresentation: Presentation {
    var view: UIView = UIView()

    private var button = UIButton()
            .with(title: "Войти")
            .with(backgroundColor: .black)

    private var passwordField = UITextField()
            .with(placeholder: "Code")

    private let leadingTo: (Token) -> (UIViewController)
    private let authority: Authority
    private let disposeBag = DisposeBag()

    init(authority: Authority, leadingTo: @escaping (Token) -> (UIViewController)) {
        self.authority = authority
        self.leadingTo = leadingTo

        let label = UILabel()
                .with(numberOfLines: 0)
                .with(text: "Use code '0114'")
                .with(textColor: .lightGray)
        let stack = UIStackView(arrangedSubviews: [passwordField, button, label])
        stack.spacing = 16
        stack.alignment = .fill
        stack.axis = .vertical

        passwordField.keyboardType = .numberPad
        passwordField.autocorrectionType = .no
        passwordField.borderStyle = .roundedRect

        view.backgroundColor = .white
        view.addSubview(stack)
        stack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(200)
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.equalToSuperview().inset(40)

        }

        button.rx.controlEvent(.touchDown).subscribe(onNext: { [unowned self] in
            self.button.backgroundColor = self.button.backgroundColor?.withAlphaComponent(0.5)
            self.button.titleLabel?.alpha = 0.8
        }).disposed(by: disposeBag)

        button.rx.controlEvent([.touchCancel, .touchUpOutside, .touchUpInside]).subscribe(onNext: { [unowned self] in
            self.button.backgroundColor = self.button.backgroundColor?.withAlphaComponent(1)
            self.button.titleLabel?.alpha = 1
        }).disposed(by: disposeBag)

        button.rx.tap
                .subscribe(onNext: { [unowned self] in
                    self.authority.confirm(code: self.passwordField.text ?? "")
                })
                .disposed(by: disposeBag)
    }

    func willAppear() {
        passwordField.becomeFirstResponder()
    }

    func wantsToPerform() -> Observable<Transition> {
        return authority.authenticate().map { [unowned self] token in
            NewWindowRootControllerTransition(leadingTo: { self.leadingTo(token) })
        }
    }
}
