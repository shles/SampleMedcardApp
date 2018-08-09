//
// Created by Артмеий Шлесберг on 09/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit

class AllBadHabitsPresentation: Presentation {

    var view: UIView = UIView()

    private var badHabtsPresentation: BadHabitsTableViewPresentation
    private let navBar = NavigationBarWithBackButton(title: "Вредные привычки")
            .with(gradient: [.wheatTwo, .rosa])
    private let addButton = UIButton()
            .with(title: "Добавить")
            .with(backgroundColor: .rosa)
//            .with(gradient: [.wheatTwo, .rosa])
            .with(roundedEdges: 24)

    private let disposeBag = DisposeBag()

    init(badHabits: ObservableBadHabits) {
        badHabtsPresentation = BadHabitsTableViewPresentation(observableHabits: badHabits)

        view.addSubviews([badHabtsPresentation.view, navBar, addButton])

        navBar.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(120)
        }

        badHabtsPresentation.view.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(navBar.snp.bottom)
        }

        addButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().inset(8)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
        }

//        Observable.combineLatest(
//                        badHabtsPresentation.habits.asObservable(),
//                        addButton.rx.tap.asObservable(),
//                        resultSelector: { habits, _ in
//            return habits
//        }).debug()
//        .subscribe(onNext: {
//            print($0.filter { $0.isSelected.value })
//        }).disposed(by: disposeBag)

        addButton.rx.controlEvent(.touchDown).subscribe(onNext: { [unowned self] in
            self.addButton.backgroundColor = self.addButton.backgroundColor?.withAlphaComponent(0.5)
            self.addButton.titleLabel?.alpha = 0.8
        }).disposed(by: disposeBag)

        addButton.rx.controlEvent([.touchCancel, .touchUpOutside, .touchUpInside]).subscribe(onNext: { [unowned self] in
            self.addButton.backgroundColor = self.addButton.backgroundColor?.withAlphaComponent(1)
            self.addButton.titleLabel?.alpha = 1
        }).disposed(by: disposeBag)
    }

    func willAppear() {

    }

    func wantsToPush() -> Observable<UIViewController> {
        return Observable.merge([navBar.wantsToPush(),badHabtsPresentation.wantsToPush()])
    }

    func wantsToPresent() -> Observable<UIViewController> {
        return Observable.merge([navBar.wantsToPresent(),badHabtsPresentation.wantsToPresent()])
    }

    func wantsToPop() -> Observable<Void> {
        return Observable.merge([navBar.wantsToPop(), badHabtsPresentation.wantsToPop(), addButton.rx.tap.asObservable()])
    }

    func wantsToBeDismissed() -> Observable<Void> {
        return Observable.merge([navBar.wantsToBeDismissed(),badHabtsPresentation.wantsToBeDismissed()])
    }
}
