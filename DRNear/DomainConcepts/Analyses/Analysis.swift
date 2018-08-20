//
// Created by Артмеий Шлесберг on 16/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit

protocol MedicalTest: Named, Dated, Described, SystemRelated, Editable, Deletable, Identified, Interactive {

}

protocol ObservableMedicalTests: DatedListRepresentable {

  func asObservable() -> Observable<[MedicalTest]>

}

extension ObservableMedicalTests {
    func toListRepresentable() -> Observable<[DatedListApplicable]> {
        return asObservable().map { $0.map { $0 as DatedListApplicable } }
    }
}

class SimpleMedicalTest: MedicalTest, ContainFiles {
    private(set) var name: String = "Анализ крови"
    private(set) var date: Date = Date()
    var description: String = "Лаборатория NKL №122 Лабораторные исследования"

    private var deletionSubject = PublishSubject<Void>()
    private var interactionSubject = PublishSubject<Void>()
    private var editionSubject = PublishSubject<Void>()

    func delete() {
        deletionSubject.onNext(())
    }

    func wantsToPerform() -> Observable<Transition> {
        return Observable.merge([
            deletionSubject.map { [unowned self] _ in
                PresentTransition(leadingTo: {
                            ViewController(
                                    presentation: DeletionPresentation(
                                            title: "Вы уверены, что хотите удалить \"\(self.name)\"?",
                                            onAccept: {}
                                    )
                            )
                        }
                )
            },
         interactionSubject.debug("interacted with \(self.description)").map { [unowned self] _ in
                PushTransition(leadingTo: {
                    ViewController(presentation: DatedDescribedFileContainedPresentation(item: self))
                })
            },
            editionSubject.map { [unowned self] _ in
                PushTransition(leadingTo: {
                    ViewController(presentation: MedicalTestEditingPresentation(medTest: self))
                })
            }
            ])
    }

    private(set) var isRelatedToSystem: Bool = false

    func edit() {
        editionSubject.onNext(())
    }

    private(set) var identification: String = ""

    func interact() {
        interactionSubject.onNext(())
    }

    private(set) var files: [File] = []
}

class SimpleMyMedicalTests: ObservableMedicalTests {

    private let tests = [
        SimpleMedicalTest(),
        SimpleMedicalTest()]

    func asObservable() -> Observable<[MedicalTest]> {
        return Observable.just(tests)
    }
}

class MedicalTestEditingPresentation: Presentation {

    private(set) var view: UIView = UIView()

    private let navBar: NavigationBarWithBackButton

    private var nameField = UITextField()
            .with(placeholder: "Название исследования")
            .with(placeholderColor: .blueyGrey)
            .with(placeholderFont: .subtitleText13)
            .with(font: .medium13)
            .with(texColor: .mainText)

    private var dateField = UITextField()
            .with(placeholder: "Дата")
            .with(placeholderColor: .blueyGrey)
            .with(placeholderFont: .subtitleText13)
            .with(font: .medium13)
            .with(texColor: .mainText)

    private var laboratoryField = UITextField()
            .with(placeholder: "Лаборатория")
            .with(placeholderColor: .blueyGrey)
            .with(placeholderFont: .subtitleText13)
            .with(font: .medium13)
            .with(texColor: .mainText)

    private var typeField = UITextField()
            .with(placeholder: "Тип исследования")
            .with(placeholderColor: .blueyGrey)
            .with(placeholderFont: .subtitleText13)
            .with(font: .medium13)
            .with(texColor: .mainText)

    private var addFileButton = UIButton()
            .with(title: "Прикрепить файл")
            .with(image: #imageLiteral(resourceName: "attachment"))
            .with(titleColor: .blueyGrey)

    convenience init(medTest: MedicalTest) {

        self.init()

        nameField.text = medTest.name

        let formatter = DateFormatter()

        formatter.dateFormat = "dd MM YYYY"
        dateField.text = formatter.string(from: medTest.date)

        laboratoryField.text = medTest.description

        //TODO: possibly mistake in fields of medTest

    }

    init() {

        navBar = NavigationBarWithBackButton(title: "Добавить")
                .with(gradient: [.darkSkyBlue, .tiffanyBlue])

        let stack = UIStackView(
                arrangedSubviews: [nameField, dateField, laboratoryField, typeField, addFileButton].map {
                    FieldContainer(view: $0)
                }
        )

        stack.axis = .vertical

        let scrollView = UIScrollView()

        scrollView.addSubview(stack)
        view.addSubviews([navBar, scrollView])

        stack.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.width.equalTo(view)
        }

        scrollView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.top.equalTo(navBar.snp.bottom)
        }

        navBar.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(120)
        }
    }

    func willAppear() {

    }

    func wantsToPerform() -> Observable<Transition> {
        return Observable.never()
    }
}

class FieldContainer: UIView {

    var content: UIView

    init(view: UIView) {
        self.content = view

        let separator = UIView()
            .with(backgroundColor: .blueyGrey)

        super.init(frame: .zero)

        addSubviews([content, separator])

        content.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.top.equalToSuperview().offset(28)
            $0.bottom.equalToSuperview().inset(16)

            $0.height.equalTo(16)
        }

        separator.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Storyboards are deprecated!")
    }
}

class AddFilePresentation: Presentation {
    private(set) var view: UIView = UIView()

    private var nameField = UITextField()

    private var rotateButton = UIButton()
    private var deleteButton = UIButton()
    private var attachButton = UIButton()
    private var filePreview = UIImageView()

    init() {

        /*
        TODO:
         - make constrains
         - make transition to select image from library
         - make injection of completion action
        */

        
    }

    func willAppear() {

    }

    func wantsToPerform() -> Observable<Transition> {
        fatalError("wantsToPerform() has not been implemented")
    }
}
