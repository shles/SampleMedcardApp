//
// Created by Артмеий Шлесберг on 24/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import RxSwift
import SnapKit
import UIKit
import RxCocoa

class AccountCreationPresentation: Presentation {

    private var photo = UIImageView()
    .with(image: #imageLiteral(resourceName: "defaultPhoto"))
    .with(roundedEdges: 50)

    private var surnameLabel = UITextField()
    .with(font: .medium13)
    .with(placeholderFont: .subtitleText13)
    .with(texColor: .mainText)
    .with(placeholderColor: .shadow)
    .with(placeholder: "Фамилия")
    private var nameLabel = UITextField()
    .with(font: .medium13)
    .with(placeholderFont: .subtitleText13)
    .with(texColor: .mainText)
    .with(placeholderColor: .shadow)
    .with(placeholder: "Имя")
    private var secondNameLabel = UITextField()
    .with(font: .medium13)
    .with(placeholderFont: .subtitleText13)
    .with(texColor: .mainText)
    .with(placeholderColor: .shadow)
    .with(placeholder: "Отчество")
    private var birthDateLabel = DatePickerTextField()
    .with(font: .medium13)
    .with(placeholderFont: .subtitleText13)
    .with(texColor: .mainText)
    .with(placeholderColor: .shadow)
    .with(placeholder: "Дата рождения")
    private var emailLabel = UITextField()
    .with(font: .medium13)
    .with(placeholderFont: .subtitleText13)
    .with(texColor: .mainText)
    .with(placeholderColor: .shadow)
    .with(placeholder: "E-Mail")

    private var genderView = GenderSelectionView()
    private var confirmButton = UIButton()
            .with(title: "Продолжить")
            .with(backgroundColor: .mainText)
            .with(roundedEdges: 24)

    private let navBar: SimpleNavigationBar

    private var commitment: AccountCommitment
    private let scrollView = TPKeyboardAvoidingScrollView()

    private var gender: Gender?

    private let transitionSubject = PublishSubject<Transition>()
    
    private let photoButton = UIButton()

    private let imageAttachement = ImageFromLibrary()

    init(commitment: AccountCommitment) {

        emailLabel.keyboardType = .emailAddress
        emailLabel.autocorrectionType = .no

        self.commitment = commitment

        navBar = SimpleNavigationBar(title: "Регистрация")

        let stack = UIStackView(
                arrangedSubviews: [surnameLabel, nameLabel, secondNameLabel, birthDateLabel, genderView, emailLabel].map {
                    FieldContainer(view: $0)
                }
        )

        stack.axis = .vertical

        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)

//        self.view = scrollView

        let containerView = UIView()

        scrollView.addSubview(containerView)

        containerView.addSubviews([photo, photoButton, stack])

        view.addSubviews([scrollView, navBar, confirmButton])

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(view)
        }

        scrollView.snp.makeConstraints {
//            $0.top.equalTo(topLayoutGuide.snp.bottom)
//            $0.bottom.equalTo(view.bottomLayoutGuide.snp.top)
            $0.bottom.leading.trailing.equalToSuperview()
            $0.top.equalTo(navBar.snp.bottom)
        }

        photo.snp.makeConstraints {
            $0.centerX.equalTo(stack)
            $0.top.equalToSuperview().offset(16)
//            $0.top.equalTo(navBar.snp.bottom).offset(16)
            $0.width.height.equalTo(100)
        }

        stack.snp.makeConstraints {
            $0.top.equalTo(photo.snp.bottom).offset(48)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(16)
            $0.width.equalTo(view)

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

        photoButton.snp.makeConstraints {
            $0.edges.equalTo(photo)
        }
        
        genderView.valueSubject.subscribe(onNext: {
            self.gender = $0
        }).disposed(by: disposeBag)

        self.commitment.wantsToPerform().bind(to: transitionSubject).disposed(by: disposeBag)

        confirmButton.rx.tap.subscribe(onNext: {
            guard let name = self.nameLabel.text,
                    let surname = self.surnameLabel.text,
//                    let date = Date(),
                    let gender = self.gender else {
                self.transitionSubject.onNext(ErrorAlertTransition(error: RequestError(message: "Заполните все обязательные поля")))
                return
            }

            commitment.commitAccountInformation(information: AccountInformationFrom(
                    name: name,
                    lastName: surname,
                    middleName: self.secondNameLabel.text ?? "",
                    birthDate: self.birthDateLabel.datePicker.date,
                    gender: gender))
        }).disposed(by: disposeBag)
        
        photoButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.imageAttachement.pickImage()
        }).disposed(by: disposeBag)
        
        imageAttachement.image.subscribe(onNext: {
            self.photo.image = $0
        }).disposed(by: disposeBag)
        
        imageAttachement.wantsToPerform().bind(to: transitionSubject).disposed(by: disposeBag)
        
    }
    
    let disposeBag = DisposeBag()
    
    private(set) var view: UIView = UIView()
    
    func willAppear() {

    }

    func wantsToPerform() -> Observable<Transition> {
        return  transitionSubject
    }
}

class GenderSelectionView: UIView {

    class RadioButton: UIButton {

        private let nonSelectedImage = #imageLiteral(resourceName: "radioButtonEmpty")
        private let selectedImage = #imageLiteral(resourceName: "radioButtonChoosed")

        private var disposeBag = DisposeBag()

        private var deselectOn: Observable<Void>

        var isChosen: Bool = false {
            didSet {
                setImage(isChosen ? selectedImage : nonSelectedImage, for: .normal)
            }
        }

        init<Value>(value: Value, selectionObserver observer: AnyObserver<Value>, deselectOn: Observable<Void>) {
            self.deselectOn = deselectOn
            super.init(frame: .zero)

            self.rx.tap.subscribe(onNext: { [unowned self] in
                self.isChosen = !self.isChosen
                if self.isChosen {
                    observer.onNext(value)
                }
            }).disposed(by: disposeBag)

            self.deselectOn.subscribe(onNext: {
                self.isChosen = false
            }).disposed(by: disposeBag)

            setImage(nonSelectedImage, for: .normal)
            self.imageView?.contentMode = .scaleAspectFit
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("storyboards are deprecated")
        }
    }

    let valueSubject = PublishSubject<Gender>()

    init() {
        super.init(frame: .zero)

        let stack = UIStackView(arrangedSubviews: [
            UILabel()
                .with(font: .regular16)
                .with(textColor: .mainText)
                .with(text: "Пол"),
            RadioButton(
                    value: Gender.male,
                    selectionObserver: valueSubject.asObserver(),
                    deselectOn: valueSubject.filter{ $0 != .male}.map{_ in()}
            )
                .with(title: "Мужской")
                .with(titleColor: .mainText),
            RadioButton(
                    value: Gender.female,
                    selectionObserver: valueSubject.asObserver(),
                    deselectOn: valueSubject.filter{ $0 != .female}.map{_ in()}
            )
                .with(title: "Женский")
                .with(titleColor: .mainText)
        ])

        stack.axis = .horizontal
        stack.spacing = 48
        self.addSubview(stack)
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are deprecated")
    }
}


class ImageFromLibrary: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var transitionsSubject = PublishSubject<Transition>()
    private let imagePicker = UIImagePickerController()
    
    func pickImage() {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        imagePicker.delegate = self
        
        transitionsSubject.onNext(PresentTransition { [unowned self] in self.imagePicker })
        
    }
    
    func wantsToPerform() -> Observable<Transition> {
        return transitionsSubject
    }
    
    private var fileSubject = PublishSubject<UIImage>()
    var image: Observable<UIImage> {
        return fileSubject
    }
    private var addFilePresentation: AddFilePresentation!
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            picker.dismiss(animated: true, completion: { [unowned self] in
                self.fileSubject.onNext(pickedImage)
            })
        } else {
            picker.dismiss(animated: true)
        }
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
