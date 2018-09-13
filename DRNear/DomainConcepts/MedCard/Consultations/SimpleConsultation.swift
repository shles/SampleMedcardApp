//
//  SimpleConsultation.swift
//  DRNear
//
//  Created by Igor Shmakov on 18/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

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

    private var diagnoseButton = UIButton()
        .with(title: "Диагноз")
        .with(titleColor: .mainText)

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
        if consultation.description != "" {
            diagnoseButton.setTitle(consultation.description, for: .normal)
        }

        //TODO: possibly mistake in fields of medTest

    }

    private var transitionSubject = PublishSubject<Transition>()

    private var files: [File] = []

    private var diagnoseUpdate = DiagnoseUpdate()

    class DiagnoseUpdate: Update {

        var itemToSelect: (Identified & Named)!
        private var transitionSubject = PublishSubject<Transition>()
        var itemSubject = PublishSubject<Identified & Named>()

        func addItem(item: Identified) {
            if let item = item as? Identified & Named {
                itemToSelect = item
                apply()
            }
        }

        func removeItem(item: Identified) {

        }

        func apply() {
            if itemToSelect != nil {
                itemSubject.onNext(itemToSelect)
                transitionSubject.onNext(PopTransition())
            }
        }

        func wantsToPerform() -> Observable<Transition> {
            return transitionSubject
        }

    }

    init(token: Token) {

        fileAttachment = ImageAttachmentFromLibrary(token: token)
        navBar = NavigationBarWithBackButton(title: "Добавить консультацию")
                .with(gradient: [.lightPeriwinkle, .softPink])

        let stack = UIStackView(
                arrangedSubviews: [nameField, dateField, diagnoseButton, addFileButton].map {
                    FieldContainer(view: $0)
                }
        )

//        diagnoseField.isEnabled
        addFileButton.contentHorizontalAlignment = .left
        diagnoseButton.contentHorizontalAlignment = .left

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

        diagnoseUpdate.itemSubject.subscribe(onNext: {
            self.diagnoseButton.setTitle($0.name, for: .normal)
        })

        diagnoseButton.rx.tap.subscribe(onNext: {
            self.transitionSubject.onNext(PushTransition(leadingTo: {
                ViewController(presentation: AllBadHabitsPresentation(
                    badHabits: AllObservableDiseasesFromAPI(token: token),
                    update: self.diagnoseUpdate,
                    title: "Выбрать диагноз",
                    gradient: [.lightPeriwinkle, .softPink]))
            }))
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
                        description: "", //self.diagnoseButton.title(for: .normal),
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
