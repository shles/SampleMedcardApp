//
//  SimpleMedicalTest.swift
//  DRNear
//
//  Created by Igor Shmakov on 18/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
//TODO: split into separate files

class MedicalTestEditingPresentation: Presentation {

    private(set) var view: UIView = UIView()

    private let navBar: NavigationBarWithBackButton

    private var nameField = UITextField()
            .with(placeholder: "Название исследования")
            .with(placeholderColor: .blueGrey)
            .with(placeholderFont: .subtitleText13)
            .with(font: .medium13)
            .with(texColor: .mainText)

    private var dateField = DatePickerTextField()
            .with(placeholder: "Дата")
            .with(placeholderColor: .blueGrey)
            .with(placeholderFont: .subtitleText13)
            .with(font: .medium13)
            .with(texColor: .mainText)

    private var laboratoryField = UITextField()
            .with(placeholder: "Лаборатория")
            .with(placeholderColor: .blueGrey)
            .with(placeholderFont: .subtitleText13)
            .with(font: .medium13)
            .with(texColor: .mainText)

    private var typeField = UITextField()
            .with(placeholder: "Тип исследования")
            .with(placeholderColor: .blueGrey)
            .with(placeholderFont: .subtitleText13)
            .with(font: .medium13)
            .with(texColor: .mainText)

    private var addFileButton = UIButton()
            .with(title: " Прикрепить файл")
            .with(image: #imageLiteral(resourceName: "attachment"))
            .with(titleColor: .blueGrey)

    private var confirmButton = GradientButton(colors:  [.darkSkyBlue, .tiffanyBlue])
            .with(title: "Сохранить")
            .with(roundedEdges: 24)

    private let fileAttachment: FilePicking

    private var medTest: MedicalTest!
    private var onSave: (() -> Observable<Void>)?

    convenience init(medTest: MedicalTest, onSave: @escaping () -> Observable<Void>) {

        self.init(token: TokenFromString(string: ""))

        self.medTest = medTest
        self.onSave = onSave
        self.files = medTest.files

        nameField.text = medTest.name

        let formatter = DateFormatter()

        formatter.dateFormat = "dd MM YYYY"
        dateField.text = formatter.string(from: medTest.date)

        laboratoryField.text = medTest.description

        //TODO: possibly mistake in fields of medTest

    }

    private var transitionSubject = PublishSubject<Transition>()

    private var files: [File] = []

    init(token: Token) {

        fileAttachment = ImageAttachmentFromLibrary(token: token)
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

        addFileButton.contentHorizontalAlignment = .left

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
            if  self.medTest != nil, let onSave = self.onSave {
                self.medTest.files = self.files
                onSave()
            } else {
                let test = MyMedicalTestFrom(
                        name: self.nameField.text ?? "",
                        id: "",
                        date: self.dateField.datePicker.date,
                        description: self.laboratoryField.text ?? "",
                        token: token,
                        files: self.files)
                test.create()
                test.wantsToPerform().debug().bind(to: self.transitionSubject)
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

class FieldContainer: UIView {

    var content: UIView

    init(view: UIView, height: CGFloat? = 24) {
        self.content = view

        let separator = UIView()
            .with(backgroundColor: .shadow)

        super.init(frame: .zero)

        addSubviews([content, separator])

        content.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.top.equalToSuperview().offset(24)
            $0.bottom.equalToSuperview().inset(12)
            if let height = height {
                $0.height.equalTo(height)
            }
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
    .with(backgroundColor: .white)

    private var nameField = UITextField()
            .with(placeholder: "Название файла")
            .with(placeholderColor: .blueGrey)
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

    private let transitionSubject = PublishSubject<Transition>()

    private let disposeBag = DisposeBag()

    init(image: UIImage, token: Token) {

        /*
        TODO: make injection of completion action
        TODO: make image rotration
        TODO: make image deletion
        */

        upload = ImageUploadToAPI(token: token, image: image )
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
            $0.height.equalTo(stack.snp.width)
//            $0.width.equalTo(236)
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

        addButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.upload.upload(name: self.nameField.text ?? "image_\(Date().fullString)")
        }).disposed(by: disposeBag)

        rotateButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.filePreview.transform = self.filePreview.transform.rotated(by: .pi / 2)// CGAffineTransform(rotationAngle: .pi / 2)
        }).disposed(by: disposeBag)

        deleteButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.transitionSubject.onNext(DismissTransition())
        }).disposed(by: disposeBag)

        upload.wantsToPerform().bind(to: transitionSubject).disposed(by: disposeBag)
        navBar.wantsToPerform().map {
            if $0 is PopTransition {
                return DismissTransition()
            } else {
                return $0
            }
        }.bind(to: transitionSubject).disposed(by: disposeBag)

    }

    var file: Observable<File> {
        return upload.file
    }

    func willAppear() {

    }

    func wantsToPerform() -> Observable<Transition> {
        return  transitionSubject
    }
}

protocol FilePicking: TransitionSource {

    func pickFile()
    var file: Observable<File> { get }
}

protocol FileUpload: TransitionSource {
    func upload(name: String)
    var file: Observable<File> { get }
}

class ImageAttachmentFromLibrary: NSObject, FilePicking, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private var transitionsSubject = PublishSubject<Transition>()
    private let imagePicker = UIImagePickerController()

    init(token: Token ) {
        self.token = token
    }

    func pickFile() {

        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary

        imagePicker.delegate = self

//        imagePicker.navigationBar.topItem?.rightBarButtonItem?.tintColor = .blue

        transitionsSubject.onNext(PresentTransition(leadingTo: { [unowned self] in self.imagePicker }))

    }

    func wantsToPerform() -> Observable<Transition> {
        return transitionsSubject
    }

    private var fileSubject = PublishSubject<File>()
    var file: Observable<File> {
        return fileSubject
    }
    private var addFilePresentation: AddFilePresentation!
    private var token: Token

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            addFilePresentation = AddFilePresentation(image: pickedImage, token: token)
            picker.dismiss(animated: true, completion: { [unowned self] in
                self.transitionsSubject.onNext(PresentTransition {
                    ViewController(presentation: self.addFilePresentation)
                })
            })
        } else {
            picker.dismiss(animated: true)
        }

        addFilePresentation.file.bind(to: fileSubject)
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
