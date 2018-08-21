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

    private let fileAttachment: FilePicking

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

        fileAttachment = ImageAttachmentFromLibrary()
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

        addFileButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.fileAttachment.pickFile()
        })
    }

    func willAppear() {

    }

    func wantsToPerform() -> Observable<Transition> {
        return Observable.merge([
            fileAttachment.wantsToPerform(),
            navBar.wantsToPerform()
        ])
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
            .with(placeholder: "Название файла")
            .with(placeholderColor: .blueyGrey)
            .with(placeholderFont: .subtitleText13)
            .with(font: .medium13)
            .with(texColor: .mainText)

    private var rotateButton = UIButton()
         .with(image: #imageLiteral(resourceName: "reload"))
    private var deleteButton = UIButton()
            .with(image: #imageLiteral(resourceName: "trash"))
    private var filePreview = UIImageView()
        .with(contentMode: .scaleAspectFit)

    private let addButton: GradientButton
    private let upload: FileUpload
    private let navBar: NavigationBarWithBackButton

    init(image: UIImage) {

        /*
        TODO: make injection of completion action
        TODO: make image rotration
        TODO: make image deletion
        todo: inject token
        */

        upload = ImageUploadToAPI(token: TokenFromString(string: ""), image: image)
        filePreview.image = image

        addButton = GradientButton(colors: [.darkSkyBlue, .tiffanyBlue])
                .with(title: "Прикрепить")
                .with(roundedEdges: 24)
                .with(backgroundColor: .darkSkyBlue)
                .with(contentMode: .scaleAspectFit)

        navBar = NavigationBarWithBackButton(title: "Добавить")
            .with(gradient: [.darkSkyBlue, .tiffanyBlue])

        let buttonsStack = UIStackView(arrangedSubviews: [rotateButton, deleteButton])

        buttonsStack.axis = .horizontal
        buttonsStack.distribution = .fillProportionally
        buttonsStack.spacing = 50

        let stack = UIStackView(arrangedSubviews: [FieldContainer(view: nameField), buttonsStack, filePreview])

        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center

        view.addSubviews([stack, navBar, addButton])

        stack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(navBar.snp.bottom)
        }

        navBar.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(120)
        }

        filePreview.snp.makeConstraints {
            $0.width.equalToSuperview().inset(16)
            $0.height.equalTo(236)

        }

        nameField.snp.makeConstraints {
            $0.width.equalTo(filePreview)
        }

        buttonsStack.snp.makeConstraints {
            $0.height.equalTo(21)
        }

        addButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().inset(8)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
        }


    }

    func willAppear() {

    }

    func wantsToPerform() -> Observable<Transition> {
        return upload.wantsToPerform()
    }
}

protocol FilePicking: TransitionSource {

    func pickFile()

}

protocol FileUpload: TransitionSource {
    func upload()
}

class ImageAttachmentFromLibrary: NSObject, FilePicking, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private var transitionsSubject = PublishSubject<Transition>()
    private let imagePicker = UIImagePickerController()

    func pickFile() {

        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary

        imagePicker.delegate = self

        transitionsSubject.onNext(PresentTransition { [unowned self] in self.imagePicker })

    }

    func wantsToPerform() -> Observable<Transition> {
        return transitionsSubject
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            picker.dismiss(animated: true, completion:  { [unowned self] in
                self.transitionsSubject.onNext(PresentTransition {
                    ViewController(presentation: AddFilePresentation(image: pickedImage))
                })
            })
        } else {
            picker.dismiss(animated: true)
        }
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

class ImageUploadToAPI: FileUpload {

    private var transitionsSubject = PublishSubject<Transition>()
    private let token: Token
    private let image: UIImage

    init(token: Token, image: UIImage) {
        self.token = token
        self.image = image
    }

    func wantsToPerform() -> Observable<Transition> {
        return transitionsSubject
    }

    func upload() {
        transitionsSubject.onNext(DismissTransition())
    }
}

