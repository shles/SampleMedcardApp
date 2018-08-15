//
// Created by Артмеий Шлесберг on 09/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import UIKit
import RxSwift

class MyBadHabitsPresentation: Presentation {

     var view: UIView = UIView()

    private var badHabtsPresentation: BadHabitsTableViewPresentation
    private let navBar: NavigationBarWithBackButton

    private let transitionSubject = PublishSubject<Transition>()
    private let leadingTo: () -> (UIViewController)
    private let button = UIButton().with(image: #imageLiteral(resourceName: "addIcon"))
    private let disposeBag = DisposeBag()
    
    init(badHabits: ObservableBadHabits, leadingTo: @escaping () -> (UIViewController) ) {
        badHabtsPresentation = BadHabitsTableViewPresentation(observableHabits: badHabits)
        self.leadingTo = leadingTo

        navBar = NavigationBarWithBackButton(title: "Вредные привычки")
                .with(gradient: [.wheatTwo, .rosa])
                .with(rightInactiveButton: button)

        view.addSubviews([badHabtsPresentation.view, navBar])

        navBar.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(120)
        }

        badHabtsPresentation.view.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(navBar.snp.bottom)
        }

        badHabtsPresentation.selection.do(onNext: { ($0 as? Deletable)?.delete() })
            .flatMap { ($0 as? Deletable)?.wantsToPerform() ?? Observable.just(ErrorAlertTransition(error: RequestError()))}
            .bind(to: transitionSubject).disposed(by: disposeBag)
    }

    func willAppear() {
        badHabtsPresentation.willAppear()
    }

    func wantsToPerform() -> Observable<Transition> {
        return Observable.merge([
            button.rx.tap.map { self.leadingTo() }.map { vc in PushTransition(leadingTo: { vc }) },
            badHabtsPresentation.wantsToPerform()
        ]).catchError { error in
            Observable.just(ErrorAlertTransition(error: error))
          }
    }
}
