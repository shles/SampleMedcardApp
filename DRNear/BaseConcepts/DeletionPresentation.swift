//
// Created by Артмеий Шлесберг on 15/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import RxSwift
import UIKit
import SnapKit

class LoadingButton: UIButton {

    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)

    init() {
        super.init(frame: .zero)
        self.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    func startAnimation() {
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2, animations: {
            self.titleLabel?.alpha = 0
            self.activityIndicator.alpha = 1
        })
    }

    func stopAnimation() {
        activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.2, animations: {
            self.titleLabel?.alpha = 1
            self.activityIndicator.alpha = 0
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboard are deprecated")
    }
}

class DeletionPresentation: Presentation {

    private(set) var view: UIView = UIView()
            .with(backgroundColor: UIColor.mainText.withAlphaComponent(0.5))
    private var deleteButton = LoadingButton()
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

    init(title: String, onAccept: @escaping () -> Observable<Void>) {

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
                .do(onNext: {[unowned self] in self.deleteButton.startAnimation() })
                .flatMap { _ in  onAccept() }
                .catchErrorJustReturn(())
                .map { DismissTransition() }
                .do(onNext: {[unowned self] _ in self.deleteButton.stopAnimation() })
                .bind(to: transitionsSubject)
                .disposed(by: disposeBag)
    }

    func willAppear() {

    }

    func wantsToPerform() -> Observable<Transition> {
        return transitionsSubject.asObservable()
    }
}
