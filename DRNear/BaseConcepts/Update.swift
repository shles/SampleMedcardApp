//
// Created by Артмеий Шлесберг on 14/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Alamofire
import Foundation
import RxSwift
import SnapKit

protocol Update: TransitionSource {

    func addItem(item: Identified)

    func removeItem(item: Identified)

    func apply()

}

protocol AdditionalInfoPresentation: Presentation {

    func info() -> String

}

class CommentPresentation: AdditionalInfoPresentation {
    func info() -> String {
        return ""
    }

    private(set) var view: UIView = UIView()
            .with(backgroundColor: .clear)

    private var addButton: GradientButton

    private var cancelButton = UIButton()
        .with(image: #imageLiteral(resourceName: "cancel"))
        .with(tint: .blueGrey)
    private var transitionsSubject = PublishSubject<Transition>()
    private var disposeBag = DisposeBag()
    private var commentField = UITextField()
        .with(placeholder: "Комментарий")

    init(title: String, gradient: [UIColor], onAccept: @escaping (String) -> Void) {

        let titleLabel = UILabel()
                .with(font: .regular)
                .with(textColor: .mainText)
                .with(numberOfLines: 2)
                .with(text: title)
                .aligned(by: .center)

        let containerView = UIView()
                .with(backgroundColor: .white)
                .with(roundedEdges: 4)

        addButton = GradientButton(colors: gradient)
                .with(title: "Добавить")
                .with(backgroundColor: .mainText)
                .with(roundedEdges: 24)

        commentField.borderStyle = .roundedRect

        view.backgroundColor = .black

        view.addSubview(containerView)
        containerView.addSubviews([titleLabel, addButton, commentField, cancelButton])

        containerView.snp.makeConstraints {
            $0.center.equalToSuperview().priority(.medium)
            $0.height.equalTo(236)
            $0.width.equalToSuperview().inset(8)
            $0.bottom.greaterThanOrEqualToSuperview().inset(400).priority(.high)
        }

        addButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(24)
        }

        titleLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(176)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
        }

        commentField.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(120)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(40)
        }


        cancelButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.height.width.equalTo(48)
        }

        cancelButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        cancelButton.rx.tap
                .map { DismissTransition() }
                .bind(to: transitionsSubject)
                .disposed(by: disposeBag)

        //TODO: make field verification
        addButton.rx.tap

                .do(onNext: { [unowned self] _ in  onAccept(self.commentField.text ?? "") })
                .map { DismissTransition() }
                .bind(to: transitionsSubject)
                .disposed(by: disposeBag)
    }

    func willAppear() {

    }

    func wantsToPerform() -> Observable<Transition> {
        return transitionsSubject
    }
}
