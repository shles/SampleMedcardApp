//
// Created by Артмеий Шлесберг on 09/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit

protocol Searchable {

    func search(string: String)

}

class AllBadHabitsPresentation: Presentation {

    var view: UIView = UIView()

    private var badHabtsPresentation: BadHabitsTableViewPresentation
    private let navBar: NavigationBarWithBackButtonAndSearch
    private let addButton: GradientButton
    private let update: Update

    private let disposeBag = DisposeBag()

    init(badHabits: ListRepresentable & Searchable, update: Update, title: String, gradient: [UIColor]) {
        self.update = update
        badHabtsPresentation = BadHabitsTableViewPresentation(observableHabits: badHabits.toListApplicable(), tintColor: gradient.last ?? .mainText)
        navBar = NavigationBarWithBackButtonAndSearch(title: title)
                .with(gradient: gradient)
        addButton = GradientButton(colors: gradient)
                .with(title: "Добавить")
                .with(roundedEdges: 24)

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
            $0.bottom.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
        }

        badHabtsPresentation.selection.subscribe(onNext: {  [unowned self] in
            if $0.isSelected.value {
                self.update.removeItem(item: $0)
            } else {
                self.update.addItem(item: $0)
            }
            $0.select()
        }).disposed(by: disposeBag)

        addButton.rx.controlEvent(.touchDown).subscribe(onNext: { [unowned self] in
            self.addButton.backgroundColor = self.addButton.backgroundColor?.withAlphaComponent(0.5)
            self.addButton.titleLabel?.alpha = 0.8
        }).disposed(by: disposeBag)

        addButton.rx.controlEvent([.touchCancel, .touchUpOutside, .touchUpInside]).subscribe(onNext: { [unowned self] in
            self.addButton.backgroundColor = self.addButton.backgroundColor?.withAlphaComponent(1)
            self.addButton.titleLabel?.alpha = 1
        }).disposed(by: disposeBag)

        addButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.update.apply()
        }).disposed(by: disposeBag)

        navBar.searchString().subscribe(onNext: {
            badHabits.search(string: $0)
        }).disposed(by: disposeBag)

    }

    func willAppear() {

    }

    func wantsToPerform() -> Observable<Transition> {
        return Observable.merge([navBar.wantsToPerform(),
                                 badHabtsPresentation.wantsToPerform(),
                                 update.wantsToPerform()
        ])
    }
}
