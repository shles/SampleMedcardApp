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
import LocalAuthentication

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
//        transitionSubject.onNext(PushTransition { [unowned self] in
//            return ViewController(presentation: PincodeConfirmationPresentation(accountCommitment: self))
//        })
    }

    func confirmPincode(code: String) {
        if self.code == code {
            // TODO: Save code
            let context = LAContext()

            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                switch context.biometryType {
                case .touchID:
                    transitionSubject.onNext( PresentTransition {
                        ViewController(presentation: BiometricIDPresentation(
                            title: "Использовать Touch ID для приложения “Доктор Рядом Телемед”?",
                            type: .touchID,
                            onAccept: { [unowned self] in
                                self.activateTouchID()
                                self.proceedToAccount()
                        }, onCancel: { [unowned self] in
                            self.proceedToAccount()
                        }))
                    })
                case .faceID:
                    transitionSubject.onNext( PresentTransition {
                        ViewController(presentation: BiometricIDPresentation(
                            title: "Использовать Face ID для приложения “Доктор Рядом Телемед”?",
                            type: .faceID,
                            onAccept: { [unowned self] in
                                self.activateFaceID()
                                self.proceedToAccount()
                        }, onCancel: { [unowned self] in
                            self.proceedToAccount()
                        }))
                    })
                case .none:
                    proceedToAccount()
                }
            } else {
                proceedToAccount()
            }
        } else {
            transitionSubject.onNext(ErrorAlertTransition(error: RequestError(message: "Pin-код не совпадает, повторите попытку")))
        }
    }

    func activateTouchID() {
//        ApplicationConfiguration.activateTouchID(forCode: self.code)

    }

    func activateFaceID() {
//        ApplicationConfiguration.activateFaceID(forCode: self.code)
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

class BiometricIDPresentation: Presentation {

    private(set) var view: UIView = UIView()
            .with(backgroundColor: UIColor.mainText.withAlphaComponent(0.5))
    private var deleteButton = UIButton()
            .with(title: "Использовать")
            .with(backgroundColor: .mainText)
            .with(roundedEdges: 24)
    private var cancelButton = UIButton()
            .with(title: "Не сейчас")
            .with(roundedEdges: 24)
            .with(titleColor: .blueGrey)
            .with(borderWidth: 1, borderColor: .blueGrey)

    private var transitionsSubject = PublishSubject<Transition>()
    private var disposeBag = DisposeBag()

    init(title: String, type: LABiometryType, onAccept: @escaping () -> Void, onCancel: @escaping () -> Void) {

        let titleLabel = UILabel()
                .with(font: .regular)
                .with(textColor: .mainText)
                .with(numberOfLines: 2)
                .with(text: title)
                .aligned(by: .center)

        let containerView = UIView()
                .with(backgroundColor: .white)
                .with(roundedEdges: 4)

        let imageView = UIImageView(image: type == .touchID ? #imageLiteral(resourceName: "touchIdIcon") : #imageLiteral(resourceName: "faceId"))
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
                .do(onNext: { _ in  onCancel() })
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
