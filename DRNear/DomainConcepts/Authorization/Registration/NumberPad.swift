//
// Created by Артмеий Шлесберг on 23/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class EnterCodeView: UIView {

    private let numberPadView = NumberPadView()
    private let codeView: CodeView
    private let codeSubject = BehaviorRelay<String>(value: "")
    private var code: String = ""
    private let disposeBag = DisposeBag()

    let codeEntered = PublishSubject<String>()

    init(title: String, image: UIImage, symbolsNumber: Int) {

        codeView = CodeView(symbolsNumber: symbolsNumber, codeSubject: codeSubject.asObservable())

        super.init(frame: .zero)

        let titleLabel = UILabel()
                .with(text: title)
                .with(font: .regular16)
                .with(textColor: .mainText)
                .aligned(by: .center)
        let imageView = UIImageView(image: image)
                .with(contentMode: .scaleAspectFit)

        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, codeView, numberPadView])

        stackView.distribution = .equalSpacing
        stackView.axis = .vertical

        self.addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(120)
            $0.width.equalTo(258)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(80)
        }

        imageView.snp.makeConstraints {
            $0.height.equalTo(40)
        }

        numberPadView.enteredNumber
            .map { [unowned self] symbol in
                 self.codeSubject.value + symbol
            }
            .bind(to: codeSubject)
            .disposed(by: disposeBag)

        numberPadView.wantsToDelete
            .map { [unowned self] symbol in
                String(self.codeSubject.value.dropLast())
            }
            .bind(to: codeSubject)
            .disposed(by: disposeBag)

        codeView.codeEntered.bind(to: codeEntered).disposed(by: disposeBag)

    }

    func clearCode() {
        codeSubject.accept("")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are deprecated")
    }

}

class CodeView: UIView {

    private let disposeBag = DisposeBag()

    class CodeSymbol: UIView {
        init() {
            super.init(frame: .zero)

            self.clipsToBounds = true
            self.backgroundColor = .shadow

            snp.makeConstraints {
                $0.width.height.equalTo(13)
            }
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            self.layer.cornerRadius = self.frame.height / 2.0
        }

        func setEntered(_ entered: Bool) {
            backgroundColor = entered ? .mainText : .shadow
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("storyboards are deprecated")
        }
    }

    private var codeSymbols: [CodeSymbol]

    let codeEntered = PublishSubject<String>()

    init(symbolsNumber: Int, codeSubject: Observable<String>) {

        codeSymbols = [CodeSymbol]()

        for _ in 1...symbolsNumber {
            codeSymbols += [CodeSymbol()]
        }

        super.init(frame: .zero)

        let stackView = UIStackView(arrangedSubviews: codeSymbols)

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 21

        addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }

        codeSubject.debug().do(onNext: { code in
            self.codeSymbols.dropFirst(code.count).forEach { $0.setEntered(false) }
            self.codeSymbols.dropLast(symbolsNumber - code.count).forEach { $0.setEntered(true) }
        }).filter { $0.count == symbolsNumber }
        .bind(to: codeEntered)
        .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are deprecated")
    }
}

class NumberPadView: UIView {

    class NumberButton: UIButton {

        private let disposeBag = DisposeBag()

        init(number: String, subjectForNumber: AnyObserver<String>) {
            super.init(frame: .zero)
            self.setTitle(number, for: .normal)
            self.backgroundColor = .shadow
            self.setTitleColor(.mainText, for: .normal)
            self.layer.cornerRadius = 33
            self.clipsToBounds = true
            self.snp.makeConstraints {
                $0.height.width.equalTo(66)
            }

            self.rx.tap.map { _ in  number }.bind(to: subjectForNumber).disposed(by: disposeBag)

            self.rx.controlEvent([.touchDown, .touchDragInside]).subscribe(onNext: { [unowned self] in
                self.backgroundColor = .mainText
                self.setTitleColor(.white, for: .normal)
            }).disposed(by: disposeBag)

            self.rx.controlEvent( [.touchUpInside, .touchDragExit, .touchCancel ]).subscribe(onNext: { [unowned self] in
                self.backgroundColor = .shadow
                self.setTitleColor(.mainText, for: .normal)
            }).disposed(by: disposeBag)

        }

        required init(coder: NSCoder) {
            fatalError("storyboards are deprecated")
        }

    }

    class ButtonsRowStack: UIStackView {
        init(views: [UIView]) {
            super.init(frame: .zero)
            views.forEach { self.addArrangedSubview($0) }
            self.axis = .horizontal
            self.alignment = .center
            self.distribution = .equalSpacing
        }

        required init(coder: NSCoder) {
            fatalError("storyboards are deprecated")
        }
    }

    class DeleteButton: UIButton {

        private let disposeBag = DisposeBag()

        init(deleteSubject: AnyObserver<Void>) {
            super.init(frame: .zero)
            self.layer.cornerRadius = 33
            self.clipsToBounds = true
            self.snp.makeConstraints {
                $0.height.width.equalTo(66)
            }
            setImage(#imageLiteral(resourceName: "backspace"), for: .normal)
            self.rx.tap.bind(to: deleteSubject).disposed(by: disposeBag)
        }

        required init(coder: NSCoder) {
            fatalError("storyboards are deprecated")
        }
    }

    class EmptyButton: UIButton {
        init() {
            super.init(frame: .zero)
            self.snp.makeConstraints {
                $0.height.width.equalTo(66)
            }
        }
        required init(coder: NSCoder) {
            fatalError("storyboards are deprecated")
        }
    }

    let enteredNumber = PublishSubject<String>()
    let wantsToDelete = PublishSubject<Void>()

    init() {
        super.init(frame: .zero)

        let rowsStack = UIStackView(arrangedSubviews: [
            ButtonsRowStack(
                    views: [
                        NumberButton(number: "1", subjectForNumber: enteredNumber.asObserver()),
                        NumberButton(number: "2", subjectForNumber: enteredNumber.asObserver()),
                        NumberButton(number: "3", subjectForNumber: enteredNumber.asObserver())
                    ]),
            ButtonsRowStack(
                    views: [
                        NumberButton(number: "4", subjectForNumber: enteredNumber.asObserver()),
                        NumberButton(number: "5", subjectForNumber: enteredNumber.asObserver()),
                        NumberButton(number: "6", subjectForNumber: enteredNumber.asObserver())
                    ]),
            ButtonsRowStack(
                    views: [
                        NumberButton(number: "7", subjectForNumber: enteredNumber.asObserver()),
                        NumberButton(number: "8", subjectForNumber: enteredNumber.asObserver()),
                        NumberButton(number: "9", subjectForNumber: enteredNumber.asObserver())
                    ]),
            ButtonsRowStack(
                    views: [
                        EmptyButton(),
                        NumberButton(number: "0", subjectForNumber: enteredNumber.asObserver()),
                        DeleteButton(deleteSubject: wantsToDelete.asObserver())
                    ])
        ])

        rowsStack.axis = .vertical
        rowsStack.spacing = 21

        addSubview(rowsStack)

        rowsStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    required init(coder: NSCoder) {
        fatalError("storyboards are deprecated")
    }
}
