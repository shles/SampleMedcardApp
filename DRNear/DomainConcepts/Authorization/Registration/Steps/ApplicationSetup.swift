//
//  ApplicationSetup.swift
//  DRNear
//
//  Created by Igor Shmakov on 20/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit

class ApplicationSetup: LoginMethodsApplication {

    private let transitionSubject = PublishSubject<Transition>()
    private let leadingTo: (Token) -> (UIViewController)
    //TODO: this means there must be separate steps
    private var code: String = ""

    init(leadingTo: @escaping (Token) -> (UIViewController)) {
        self.leadingTo = leadingTo
    }
    
    func createPincode(code: String) {
        self.code = code
        transitionSubject.onNext(PushTransition { [unowned self] in
            return ViewController(presentation: PincodeConfirmationPresentation(loginApplication: self))
        })
    }
    
    func confirmPincode(code: String) {
        if self.code == code {
            transitionSubject.onNext( PresentTransition {
                ViewController(presentation: TouchIDPresentation(
                        title: "Использовать Touch ID для приложения “Доктор Рядом Телемед”?",
                        onAccept: { [unowned self] in
                            self.activateTouchID()
                            self.proceedToAccount()
                        }))
            })
        } else {
            transitionSubject.onNext(ErrorAlertTransition(error: RequestError(message: "Pin-код не совпадает, повторите попытку")))
        }
    }
    
    func activateTouchID() {
        
    }
    
    func activateFaceID() {
        
    }
    
    func proceedToAccount() {
        let authority = AuthorityFromAPI()

        authority.authenticate().retry(10).map { [unowned self] token in
            NewWindowRootControllerTransition(leadingTo: { self.leadingTo(token) })
        }.bind(to: transitionSubject)

        authority.authWith(credentials: CredentialsFrom(login: "admin", password: "38Gjgeuftd!"))

    }

    func wantsToPerform() -> Observable<Transition> {
        return transitionSubject
    }
}

class TouchIDPresentation: Presentation {

    private(set) var view: UIView = UIView()
            .with(backgroundColor: UIColor.mainText.withAlphaComponent(0.5))
    private var deleteButton = UIButton()
            .with(title: "Использовать")
            .with(backgroundColor: .mainText)
            .with(roundedEdges: 24)
    private var cancelButton = UIButton()
            .with(title: "Не сейчас")
            .with(roundedEdges: 24)
            .with(titleColor: .blueyGrey)
            .with(borderWidth: 1, borderColor: .blueyGrey)

    private var transitionsSubject = PublishSubject<Transition>()
    private var disposeBag = DisposeBag()

    init(title: String, onAccept: @escaping () -> ()) {

        let titleLabel = UILabel()
                .with(font: .regular)
                .with(textColor: .mainText)
                .with(numberOfLines: 2)
                .with(text: title)
                .aligned(by: .center)

        let containerView = UIView()
                .with(backgroundColor: .white)
                .with(roundedEdges: 4)

        let imageView = UIImageView(image: #imageLiteral(resourceName: "touchIdIcon"))
        .with(contentMode: .scaleAspectFit)

        let horStack = UIStackView(arrangedSubviews: [cancelButton, deleteButton])

        horStack.axis = .horizontal
        horStack.spacing = 24
        horStack.distribution = .fillEqually

        view.addSubview(containerView)
        containerView.addSubviews([imageView, titleLabel, horStack])

        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(236)
            $0.width.equalToSuperview().inset(8)
        }

        horStack.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(24)
        }

        cancelButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }

        imageView.snp.makeConstraints {
            $0.height.width.equalTo(48)
            $0.bottom.equalToSuperview().inset(160)
            $0.centerX.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(96)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
        }

        deleteButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }

        cancelButton.rx.tap
                .map { DismissTransition() }
                .bind(to: transitionsSubject)
                .disposed(by: disposeBag)
        deleteButton.rx.tap
                .do(onNext: { _ in  onAccept() })
                .map { DismissTransition() }
                .bind(to: transitionsSubject)
                .disposed(by: disposeBag)
    }

    func willAppear() {

    }

    func wantsToPerform() -> Observable<Transition> {
        return transitionsSubject.asObservable()
    }
}
