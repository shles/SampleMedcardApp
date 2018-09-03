//
// Created by Артмеий Шлесберг on 24/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import RxSwift
import SnapKit
import UIKit
import PhoneNumberKit

class EnterNumberView: UIView {

    private let numberPadView = NumberPadView()
    private let numberField = PhoneNumberTextField()
            .with(texColor: .mainText)
            .with(font: .regular24)
            .with(textAlignment: .center)

    private let disposeBag = DisposeBag()

    private let confirmButton: GradientButton

    let numberEntered = PublishSubject<String>()

    init(title: String, image: UIImage, symbolsNumber: Int) {

        confirmButton = GradientButton(colors: [.mainText])
                .with(title: "Продолжить")
                .with(roundedEdges: 24)

        super.init(frame: .zero)

        numberField.isUserInteractionEnabled = false
        numberField.withPrefix = true
        numberField.defaultRegion = "RU"
        numberField.text = "+7"

        let titleLabel = UILabel()
                .with(text: title)
                .with(font: .regular16)
                .with(textColor: .mainText)
                .with(numberOfLines: 0)
                .aligned(by: .center)
        let imageView = UIImageView(image: image)
                .with(contentMode: .scaleAspectFit)

        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, numberField, numberPadView])

        stackView.distribution = .equalSpacing
        stackView.axis = .vertical

        self.addSubviews([stackView, confirmButton])

        stackView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(120)
            $0.width.equalTo(258)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(80)

        }

        imageView.snp.makeConstraints {
            $0.height.equalTo(40)
        }

        confirmButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
        }

        numberPadView.enteredNumber
                .filter { [unowned self] _ in (self.numberField.text?.count ?? 0 ) < 16 }
                .map { [unowned self] symbol in
                    return (self.numberField.text ?? "") + symbol
                }
                .bind(to: self.numberField.rx.text)
                .disposed(by: disposeBag)
        numberPadView.wantsToDelete
                .filter { [unowned self] in (self.numberField.text?.count ?? 0 ) > 2 }
                .map { [unowned self] symbol in
                    return String(self.numberField.text?.dropLast() ?? "")
                }
                .bind(to: self.numberField.rx.text)
                .disposed(by: disposeBag)

        confirmButton.rx.tap
                .map { [unowned self] in self.numberField.nationalNumber ?? "" }
                .bind(to: numberEntered)
                .disposed(by: disposeBag)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are deprecated")
    }
}

class NumberRegistrationPresentation: Presentation {

    private(set) var view: UIView = UIView()

    private var enternumberView: EnterNumberView
    private var numberRegistration: NumberRegistration

    init(numberRegistration: NumberRegistration) {
        enternumberView = EnterNumberView(
                title: "Прежде чем продолжить, введите номер телефона",
                image: #imageLiteral(resourceName: "page1Copy"),
                symbolsNumber: 6)
        self.numberRegistration = numberRegistration

        view.addSubview(enternumberView)

        enternumberView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        enternumberView.numberEntered.subscribe(onNext: {
            self.numberRegistration.register(number: $0)
        })
    }

    func willAppear() {

    }

    func wantsToPerform() -> Observable<Transition> {
        return  numberRegistration.wantsToPerform()
    }

}
