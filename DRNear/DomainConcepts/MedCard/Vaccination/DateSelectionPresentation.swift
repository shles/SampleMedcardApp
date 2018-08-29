//
// Created by Артмеий Шлесберг on 22/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import SnapKit

class DateSelectionPresentation: Presentation {

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

    private let datePicker = UIDatePicker()

    init(title: String, gradient: [UIColor], onAccept: @escaping (Date) -> Void, mode: UIDatePickerMode = .dateAndTime) {

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

        view.backgroundColor = .black

        view.addSubview(containerView)
        containerView.addSubviews([titleLabel, addButton, datePicker, cancelButton])

        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(387)
            $0.width.equalToSuperview().inset(8)
        }

        datePicker.datePickerMode = mode

        addButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(24)
        }

        titleLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(321)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
        }

        datePicker.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(99)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(216)
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
                .do(onNext: { [unowned self] _ in  onAccept(self.datePicker.date) })
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
