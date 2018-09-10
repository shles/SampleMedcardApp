//
// Created by Артмеий Шлесберг on 06/09/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit
import RxDataSources
import RxCocoa

class SimpleObservableSystemConsultations: ObservableConsultations {
    func asObservable() -> Observable<[Consultation]> {
        return Observable.just([SimpleSystemConsultation()])
    }
}

class SimpleSystemConsultation: SystemConsultation {
    private(set) var doctor: Doctor = SimpleDoctor()

    func like() {

    }

    func startChat() {

    }

    func showRecord() {

    }

    private(set) var name: String = "Консультация с терапевтом"
    private(set) var date: Date = Date()
    private(set) var description: String = "Прошедшая системная консультация"
    private(set) var isRelatedToSystem: Bool = true

    private let transitionSubject = PublishSubject<Transition>()

    func edit() {

    }

    func wantsToPerform() -> Observable<Transition> {
        return transitionSubject
    }

    func delete() {

    }

    private(set) var identification: String = ""

    func interact() {
        transitionSubject.onNext(
            PushTransition(leadingTo: {
                ViewController(presentation: SystemConsultationPresentation(item: self, gradient: [.darkSkyBlue, .tiffanyBlue]))
            })
        )
    }

    private(set) var json: [String: Any] = [:]
    var files: [File] = []
    private(set) var diagnose: String = "Я как пациент хочу узнать свой диагноз в рамках возможного представления разрешенного законодательством"
    private(set) var recommendation: String = "Я как пациент хочу узнать свой план лечения для улучшения самочувствия и здорового сна"
}

class SystemConsultationPresentation: Presentation {

    class HeaderView: UIView {

        private let diposeBag = DisposeBag()

        init(item: SystemConsultation) {

            super.init(frame: .zero)

            let doctorPhoto = UIImageView()
            .with(contentMode: .scaleAspectFit)

            item.doctor.image.asObservable().bind(to: doctorPhoto.rx.image).disposed(by: diposeBag)

            let doctorNameLabel = UILabel()
            .with(font: .medCardCell)
            .with(textColor: .mainText)
            .with(text: item.doctor.name)
            .aligned(by: .center)
            .with(numberOfLines: 2)
            let doctorSpecLAbel = UILabel()
            .with(font: .subtitleText13)
            .with(textColor: .blueGrey)
            .with(text: item.doctor.specialization)
            .aligned(by: .center)
            .with(numberOfLines: 2)
            let likeButton = UIButton()
            .with(image: #imageLiteral(resourceName: "likeIcon"))
            let chatButton = UIButton()
            .with(image: #imageLiteral(resourceName: "doctorChatIcon"))
            let videoButton = UIButton()
            .with(image: #imageLiteral(resourceName: "playIcon"))

            let buttonStack = UIStackView(arrangedSubviews: [likeButton, chatButton, videoButton])

            buttonStack.axis = .horizontal
            buttonStack.distribution = .equalCentering

            let doctorStack = UIStackView(arrangedSubviews: [doctorPhoto, doctorNameLabel, doctorSpecLAbel, buttonStack])

            doctorStack.axis = .vertical
            doctorStack.spacing = 8

            let diagnoseTitleLabel = UILabel()
            .with(font: .medium13)
            .with(textColor: .mainText)
            .with(text: "Диагноз")
            let recomendationTitleLabel = UILabel()
            .with(font: .medium13)
            .with(textColor: .mainText)
            .with(text: "Рекомендации")
            let diagnoseLabel = UILabel()
            .with(font: .subtitleText13)
            .with(textColor: .blueGrey)
            .with(numberOfLines: 0)
            .with(text: item.diagnose)
            let recomendationLabel = UILabel()
            .with(font: .subtitleText13)
            .with(textColor: .blueGrey)
            .with(numberOfLines: 0)
            .with(text: item.recommendation)
            let diagnoseStack = UIStackView(arrangedSubviews: [diagnoseTitleLabel, diagnoseLabel])

            recomendationLabel.sizeToFit()
            diagnoseStack.spacing = 4
            diagnoseStack.axis = .vertical

            let recomendationStack = UIStackView(arrangedSubviews: [recomendationTitleLabel, recomendationLabel])

            recomendationStack.spacing = 4
            recomendationStack.axis = .vertical
            
            let doctorContainer = UIView()
            
            doctorContainer.addSubview(doctorStack)

            let resultsStack = UIStackView(arrangedSubviews: [FieldContainer(view: diagnoseStack, height: nil), FieldContainer(view: recomendationStack, height: nil)])

            resultsStack.spacing = 8
            resultsStack.axis = .vertical

            let filesLabel = UILabel()
                .with(font: .medium13)
                .with(text: "Файлы")
                .with(textColor: .mainText)

            let finalStack = UIStackView(arrangedSubviews: [doctorContainer, resultsStack, filesLabel])

            finalStack.spacing = 16
            finalStack.axis = .vertical

            addSubview(finalStack)

            if item.files.isEmpty {
                filesLabel.isHidden = true
            }

            doctorPhoto.snp.makeConstraints {
                $0.width.equalTo(120)
                $0.height.equalTo(136)
            }

            doctorStack.snp.makeConstraints {
                $0.width.equalTo(152)
                $0.centerX.equalToSuperview()
                $0.top.bottom.equalToSuperview().offset(16)
            }

            finalStack.snp.makeConstraints {
                $0.edges.equalToSuperview().inset(UIEdgeInsetsMake(16, 16, 16, 16))
            }
            
            finalStack.setContentCompressionResistancePriority(.required, for: .vertical)

            
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("storyboards are deprecated!")
        }
    }

    class HeaderCell: UITableViewCell {
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            let view = HeaderView(item: SimpleSystemConsultation())
            addSubview(view)
            view.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    private let tableView = StandardTableView()
    private let navBar: NavigationBarWithBackButton
    private let disposeBag = DisposeBag()

    private let item: SystemConsultation

    init(item: SystemConsultation, gradient: [UIColor]) {
        tableView.separatorStyle = .none
        self.item = item

        navBar = NavigationBarWithBackButton(title: item.name)
            .with(gradient: gradient)

        view.addSubviews([tableView, navBar])

        navBar.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(120)
        }

        tableView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(navBar.snp.bottom)
        }


        let dataSource = RxTableViewSectionedReloadDataSource<StandardSectionModel<Void>>(configureCell: {  ds, tv, ip, item in
            return tv.dequeueReusableCellOfType(HeaderCell.self, for: ip)
        })

        Observable.from([()])
            .map { [StandardSectionModel<Void>(items: $0)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    private(set) var view: UIView = UIView()

    func willAppear() {
       
    }

    func wantsToPerform() -> Observable<Transition> {
        return navBar.wantsToPerform()
    }
}
