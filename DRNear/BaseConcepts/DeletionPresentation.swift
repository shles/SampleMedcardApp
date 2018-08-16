//
// Created by Артмеий Шлесберг on 15/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import UIKit
import RxSwift

class DeletionPresentation: Presentation {

    private(set) var view: UIView = UIView()
            .with(backgroundColor: .black)
    private var deleteButton = UIButton()
            .with(title: "Удалить")
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

        let horStack = UIStackView(arrangedSubviews: [cancelButton, deleteButton])

        horStack.axis = .horizontal
        horStack.spacing = 24
        horStack.distribution = .fillEqually

        view.addSubview(containerView)
        containerView.addSubviews([titleLabel, horStack])

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
