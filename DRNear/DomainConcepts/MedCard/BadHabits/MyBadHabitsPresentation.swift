//
// Created by Артмеий Шлесберг on 09/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import RxSwift
import UIKit

class MyBadHabitsPresentation: Presentation {

     var view: UIView = UIView()

    private var badHabtsPresentation: BadHabitsTableViewPresentation
    private let navBar: NavigationBarWithBackButton

    private let transitionSubject = PublishSubject<Transition>()
    private let leadingTo: () -> (UIViewController)
    private let button = UIButton().with(image: #imageLiteral(resourceName: "addIcon"))
    private let disposeBag = DisposeBag()

    init(badHabits: ListRepresentable, title: String, gradient: [UIColor], leadingTo: @escaping () -> (UIViewController), emptyStateView: UIView = UIView()  ) {

        badHabtsPresentation = BadHabitsTableViewPresentation(
            observableHabits: badHabits.toListApplicable(),
            tintColor: gradient.last ?? .mainText,
            emptyStateView: emptyStateView
        )

        self.leadingTo = leadingTo
        navBar = NavigationBarWithBackButton(title: title)
                .with(gradient: gradient)
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
            .flatMap { ($0 as? Deletable)?.wantsToPerform() ?? Observable.just(ErrorAlertTransition(error: RequestError())) }
            .bind(to: transitionSubject).disposed(by: disposeBag)
    }

    func willAppear() {
        badHabtsPresentation.willAppear()
    }

    func wantsToPerform() -> Observable<Transition> {
        return Observable.merge([
            button.rx.tap.map { self.leadingTo() }.map { vc in PushTransition(leadingTo: { vc }) },
            badHabtsPresentation.wantsToPerform(),
            navBar.wantsToPerform()
        ]).catchError { error in
            Observable.just(ErrorAlertTransition(error: error))
          }
    }
}

class EmptyStateView: UIView {

    init(image: UIImage, title: String, subtitle: String = "Это поможет нашим врачам и будет удобно для вас.") {

        super.init(frame: .zero)

        let imageView = UIImageView()
            .with(image: image)
            .with(contentMode: .scaleAspectFit)
        let titleLabel = UILabel()
            .with(font: .medCardCell)
            .with(text: title)
            .with(textColor: .mainText)
            .with(numberOfLines: 0)
            .aligned(by: .center)
        let subtitleLabel = UILabel()
            .with(font: .subtitleText13)
            .with(text: subtitle)
            .with(textColor: .mainText)
            .with(numberOfLines: 0)
            .aligned(by: .center)
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, subtitleLabel])

        stackView.spacing = 4
        stackView.axis = .vertical

        addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        imageView.snp.makeConstraints {
            $0.height.equalTo(300)
        }
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(47)
        }
        subtitleLabel.snp.makeConstraints {
            $0.height.equalTo(47)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are deprecated")
    }
}
