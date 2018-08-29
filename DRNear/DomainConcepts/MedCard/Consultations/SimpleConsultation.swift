//
//  SimpleConsultation.swift
//  DRNear
//
//  Created by Igor Shmakov on 18/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

class SimpleConsultation: Consultation, ContainFiles {

    private(set) var name: String = "Врач-педиатр"
    private(set) var date: Date = Date()
    var description: String = "Первичная консультация"

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
                                    onAccept: {Observable.just(())}
                            )
                    )
                }
                )
            },
            interactionSubject.debug("interacted with \(self.description)").map { [unowned self] _ in
                PushTransition(leadingTo: {
                    ViewController(presentation: DatedDescribedFileContainedPresentation(item: self, gradient: [.lightPeriwinkle, .softPink]))
                })
            },
            editionSubject.map { [unowned self] _ in
                PushTransition(leadingTo: {
                    ViewController(presentation: ConsultationEditingPresentation(consultation: self, onSave: { Observable.just(())}))
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

    var files: [File] = [FileFrom(name: "Записи с консультации", size: 11)]

    private(set) var json: [String: Any] = [:]
}

class SimpleMyConsultations: ObservableConsultations {

    private let tests = [SimpleConsultation(),
                         SimpleConsultation(),
                         SimpleConsultation()]

    func asObservable() -> Observable<[Consultation]> {
        return Observable.just(tests)
    }
}

class ConsultationEditingPresentation: Presentation {

    private(set) var view: UIView = UIView()

    private let navBar: NavigationBarWithBackButton

    private var nameField = UITextField()
            .with(placeholder: "Название консультации")
            .with(placeholderColor: .blueGrey)
            .with(placeholderFont: .subtitleText13)
            .with(font: .medium13)
            .with(texColor: .mainText)

    private var dateField = UITextField()
            .with(placeholder: "Дата")
            .with(placeholderColor: .blueGrey)
            .with(placeholderFont: .subtitleText13)
            .with(font: .medium13)
            .with(texColor: .mainText)

    private var diagnoseField = UITextField()
            .with(placeholder: "Диагноз")
            .with(placeholderColor: .blueGrey)
            .with(placeholderFont: .subtitleText13)
            .with(font: .medium13)
            .with(texColor: .mainText)

    private var addFileButton = UIButton()
            .with(title: " Прикрепить файл")
            .with(image: #imageLiteral(resourceName: "attachment"))
            .with(titleColor: .blueGrey)

    private var confirmButton = GradientButton(colors:  [.lightPeriwinkle, .softPink])
            .with(title: "Сохранить")
            .with(roundedEdges: 24)

    private let fileAttachment: FilePicking

    private var consultation: Consultation!
    private var onSave: (() -> Observable<Void>)?

    convenience init(consultation: Consultation, onSave: @escaping () -> Observable<Void>) {

        self.init(token: TokenFromString(string: ""))

        self.consultation = consultation
        self.onSave = onSave
        self.files = consultation.files

        nameField.text = consultation.name

        let formatter = DateFormatter()

        formatter.dateFormat = "dd MM YYYY"
        dateField.text = formatter.string(from: consultation.date)

//        diagnoseField.text = medTest.description

        //TODO: possibly mistake in fields of medTest

    }

    private var transitionSubject = PublishSubject<Transition>()

    private var files: [File] = []

    init(token: Token) {

        fileAttachment = ImageAttachmentFromLibrary(token: token)
        navBar = NavigationBarWithBackButton(title: "Добавить")
                .with(gradient: [.lightPeriwinkle, .softPink])

        let stack = UIStackView(
                arrangedSubviews: [nameField, dateField, diagnoseField, addFileButton].map {
                    FieldContainer(view: $0)
                }
        )

        diagnoseField.isEnabled = false

        stack.axis = .vertical

        let scrollView = UIScrollView()

        scrollView.addSubview(stack)
        view.addSubviews([navBar, scrollView, confirmButton])

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

        confirmButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
        }

        addFileButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.fileAttachment.pickFile()
        })

        fileAttachment.file.subscribe(onNext: { [unowned self] in
            self.files.append($0)
            let cell = FileCell(style: .default, reuseIdentifier: "").configured(item: $0).contentView
            scrollView.addSubview(cell)
            cell.snp.makeConstraints {
                $0.top.equalTo(stack.snp.bottom).offset(16)
                $0.width.equalTo(self.view).inset(16)
                $0.centerX.equalTo(self.view)
            }

        })

        confirmButton.rx.tap.subscribe(onNext: { [unowned self] in
            if self.consultation != nil, let onSave = self.onSave {
                self.consultation.files = self.files
                onSave()
            } else {
                let cons = MyConsultationFrom(
                        name: self.nameField.text ?? "",
                        id: "",
                        date: Date(),
                        description: self.diagnoseField.text ?? "",
                        token: token,
                        files: self.files)
                cons.create()
                cons.wantsToPerform().debug().bind(to: self.transitionSubject)
            }
        })

    }

    func willAppear() {

    }

    func wantsToPerform() -> Observable<Transition> {
        return Observable.merge([
            fileAttachment.wantsToPerform(),
            navBar.wantsToPerform(),
            transitionSubject
        ])
    }
}
