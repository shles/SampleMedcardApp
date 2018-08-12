//
// Created by Артмеий Шлесберг on 09/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import UIKit
import RxSwift

class MyBadHabitsPresentation: Presentation {

     var view: UIView = UIView()

    private var badHabtsPresentation: Presentation
    private let navBar: NavigationBarWithBackButton

    private let pushSubject = PublishSubject<UIViewController>()
    private let leadingTo: () -> (UIViewController)

    init(badHabits: ObservableBadHabits, leadingTo: @escaping () -> (UIViewController) ) {
        badHabtsPresentation = BadHabitsTableViewPresentation(observableHabits: badHabits)
        self.leadingTo = leadingTo

        let button = UIButton().with(image: #imageLiteral(resourceName: "addIcon"))

        navBar = NavigationBarWithBackButton(title: "Вредные привычки")
                .with(gradient: [.wheatTwo, .rosa])
                .with(rightInactiveButton: button)

        button.rx.tap.map {  leadingTo() }.bind(to: pushSubject)

        view.addSubviews([badHabtsPresentation.view, navBar])

        navBar.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(120)
        }

        badHabtsPresentation.view.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(navBar.snp.bottom)
        }
    }

    func willAppear() {
        badHabtsPresentation.willAppear()
    }

    func wantsToPerform() -> Observable<Transition> {
        return pushSubject.map { vc in PushTransition(leadingTo: { vc }) }
    }
}
