//
// Created by Артмеий Шлесберг on 14/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

protocol Update: TransitionSource {

    func addItem(item: Identified)

    func apply()

}

protocol AdditionalInfoPresentation: Presentation {

    func info() -> String

}

class MyBadHabitsUpdate: Update {

    private var itemsToCommit = [Identified]()
    private let token: Token
    private let disposeBag = DisposeBag()

    private let transitionSubject = PublishSubject<Transition>()

    init(token: Token) {
        self.token = token
    }

    func addItem(item: Identified) {
        itemsToCommit += [item]
    }

    func apply() {
        if let request = try? AuthorizedRequest(
                path: "/eco-emc/api/my/bad-habits",
                method: .post,
                token: token,
                parameters: itemsToCommit.map { $0.identification }.asParameters(),
                encoding: ArrayEncoding()
        ) {
            request.make().subscribe(onNext: { [unowned self] response in

                if let error = response.error {
                    self.transitionSubject.onNext(ErrorAlertTransition(error: error))
                } else {
                    self.transitionSubject.onNext(PopTransition())
                }
            }).disposed(by: disposeBag)
        }

    }

    func wantsToPerform() -> Observable<Transition> {
        return transitionSubject
    }
}

class CommentPresentation: AdditionalInfoPresentation {

    private(set) var view: UIView = UIView()
            .with(backgroundColor: .clear)

    private var addButton = UIButton()
            .with(title: "Добавить")
            .with(backgroundColor: .mainText)
            .with(roundedEdges: 24)

    private var cancelButton = UIButton()


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

        view.addSubview(containerView)
        containerView.addSubviews([titleLabel, addButton])


        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(236)
            $0.width.equalToSuperview().inset(8)
        }

        addButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(24)
        }

        cancelButton.rx.tap
                .map { DismissTransition() }
                .bind(to: transitionsSubject)
                .disposed(by: disposeBag)
        addButton.rx.tap
                .do(onNext: { _ in  onAccept() })
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
