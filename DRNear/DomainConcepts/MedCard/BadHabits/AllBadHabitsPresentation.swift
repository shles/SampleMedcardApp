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
    private let navBar = NavigationBarWithBackButtonAndSearch(title: "Вредные привычки")
            .with(gradient: [.wheatTwo, .rosa])
    private let addButton = UIButton()
            .with(title: "Добавить")
            .with(backgroundColor: .rosa)
//            .with(gradient: [.wheatTwo, .rosa])
            .with(roundedEdges: 24)

    private let disposeBag = DisposeBag()

    init(badHabits: ObservableBadHabits, update: Update)  {
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

//        Observable<BadHabit>.merge(badHabits.asObservable().flatMap { habits in
//            habits.map { habit -> Observable<BadHabit> in
//                return habit.isSelected.asObservable().map { _ in habit}
//            }
//        }).subscribe(onNext: {
//            update.addItem(item: $0)
//        }).disposed(by: disposeBag)

        badHabtsPresentation.selection.subscribe(onNext: {
            $0.select()
            update.addItem(item: $0)
        }).disposed(by: disposeBag)

        addButton.rx.controlEvent(.touchDown).subscribe(onNext: { [unowned self] in
            self.addButton.backgroundColor = self.addButton.backgroundColor?.withAlphaComponent(0.5)
            self.addButton.titleLabel?.alpha = 0.8
        }).disposed(by: disposeBag)

        addButton.rx.controlEvent([.touchCancel, .touchUpOutside, .touchUpInside]).subscribe(onNext: { [unowned self] in
            self.addButton.backgroundColor = self.addButton.backgroundColor?.withAlphaComponent(1)
            self.addButton.titleLabel?.alpha = 1
        }).disposed(by: disposeBag)

        addButton.rx.tap.subscribe(onNext: {
            update.apply()
        })
    }

    func willAppear() {

    }

    func wantsToPerform() -> Observable<Transition> {
        return Observable.merge([navBar.wantsToPerform(),
                                 badHabtsPresentation.wantsToPerform(),
                                 addButton.rx.tap.asObservable().map { PopTransition() }
        ])
    }
}
