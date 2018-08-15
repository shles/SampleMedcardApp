//
// Created by Артмеий Шлесберг on 08/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Alamofire
import Foundation
import RxSwift
import SwiftyJSON
import SnapKit

class ObservableMyBadHabitsFromAPI: ObservableBadHabits, ObservableType {

    typealias E = [BadHabit]
    private let token: Token
    private let request: Request

    init(token: Token) throws {

        request = try AuthorizedRequest(
                path: "/eco-emc/api/my/bad-habits",
                method: .get,
                token: token,
                encoding: URLEncoding.default
        )
        self.token = token
    }

    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == [BadHabit] {
        return request.make()
                .map { json in

                    json.arrayValue.map { (json: JSON) in
                        BadHabitFrom(
                                name: json["name"].string  ?? "",
                                id: json["code"].string ?? "",
                                token: self.token
                        )
                    }
                }.subscribe(observer)
    }
}

class MyBadHabitFrom: BadHabit, Deletable {

    private(set) var name: String = ""
    private(set) var identification: String = ""
    private(set) var isSelected: Variable<Bool> = Variable(true)

    private let deletionSubject = PublishSubject<Transition>()

    init(name: String, id: String) {
        self.name = name
        self.identification = id
    }

    func select() {

    }

    func delete() {
        deletionSubject.onNext(PresentTransition {
            ViewController(
                    presentation: DeletionPresentation(
                            title: "Вы точно хотите удалить привычку \"\(self.name)\"?",
                            onAccept: { }
                    )
            )
        })
    }

    func wantsToPerform() -> Observable<Transition> {
        return deletionSubject.asObservable().debug()
    }
}

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

class ObservableSimpleMyBadHabits: ObservableBadHabits {

    private let array = [
        MyBadHabitFrom(name: "aaa", id: "a"),
        MyBadHabitFrom(name: "bbb", id: "b"),
        MyBadHabitFrom(name: "ccc", id: "c"),
    ]

    func asObservable() -> Observable<[BadHabit]> {
        return Observable.just(array)
    }

}
