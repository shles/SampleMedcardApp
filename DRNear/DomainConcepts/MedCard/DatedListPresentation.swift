//
// ?Created by Артмеий Шлесберг on 16/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxCocoa
import RxDataSources
import RxSwift
import SnapKit
import UIKit

typealias DatedListApplicable = Identified & Dated & Named & Described & SystemRelated & Deletable & Editable & Interactive

protocol DatedListRepresentable {
    func toListRepresentable() -> Observable<[DatedListApplicable]>
}

class DDNListPresentation: NSObject, Presentation, UITableViewDelegate {
    var view: UIView = UIView()

    private let tableView = StandardTableView()
    private let navBar: NavigationBarWithBackButton

    private let transitionSubject = PublishSubject<Transition>()
    private let itemsSubject = ReplaySubject<[DatedListApplicable]>.create(bufferSize: 1)
    private let refreshSubject = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    private let addButton = UIButton().with(image: #imageLiteral(resourceName: "addIcon"))

    private let items: Refreshable<[DatedListApplicable]>
    private let leadingTo: () -> (UIViewController)

    private var itemsTransitionsDisposeBag = DisposeBag()

    init(items: DatedListRepresentable, title: String, gradient: [UIColor], leadingTo: @escaping () -> (UIViewController)) {

        self.leadingTo = leadingTo
        self.items = Refreshable(origin: items.toListRepresentable().catchErrorJustReturn([]), refreshOn: refreshSubject.skip(1))

        navBar = NavigationBarWithBackButton(title: title)
                .with(gradient: gradient)
                .with(rightInactiveButton: addButton)

        super.init()

        view.addSubviews([tableView, navBar])

        navBar.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(120)
        }

        tableView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(navBar.snp.bottom)
        }

        self.items.asObservable().catchErrorJustReturn([]).bind(to: itemsSubject).disposed(by: disposeBag)

        let dataSource = RxTableViewSectionedReloadDataSource<StandardSectionModel<DatedListApplicable>>(
                configureCell: { _, tv, ip, habit in
                    return tv.dequeueReusableCellOfType(DatedDescribedCell.self, for: ip).configured(item: habit)
                },
                canEditRowAtIndexPath: { _, _ in true })

        itemsSubject.asObservable()
                .map { [StandardSectionModel(items: $0)] }
                .bind(to: tableView.rx.items(dataSource: dataSource))
                .disposed(by: disposeBag)

        tableView.rx.setDelegate(self).disposed(by: disposeBag)

        tableView.rx.modelSelected(DatedListApplicable.self).subscribe(onNext: {
            $0.interact()
        }).disposed(by: disposeBag)

        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        //TODO: maybe develop new object6 that subscribes transitionsubject inside
        itemsSubject.asObservable()
        .subscribe(onNext: { [unowned self] in
            self.itemsTransitionsDisposeBag = DisposeBag()
            Observable.merge($0.map { $0.wantsToPerform() }).subscribe(onNext: {
                self.transitionSubject.onNext($0)
            }).disposed(by: self.itemsTransitionsDisposeBag)
        }).disposed(by: disposeBag)

        addButton.rx.tap
                .map { self.leadingTo() }
                .map { vc in PushTransition(leadingTo: { vc }) }
                .bind(to: transitionSubject)
                .disposed(by: disposeBag)

    }

    func willAppear() {
        refreshSubject.onNext(())
    }

    func wantsToPerform() -> Observable<Transition> {
        return Observable.merge([transitionSubject.debug(),
                                 navBar.wantsToPerform()])
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "", handler: { _, _, _ in
            if let item: DatedListApplicable = try? tableView.rx.model(at: indexPath) {
                item.delete()
            }
        })

        action.image = #imageLiteral(resourceName: "trash")
        return UISwipeActionsConfiguration(actions: [action])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let action = UIContextualAction(style: .normal, title: "", handler: { _, _, _ in
            if let item: DatedListApplicable = try? tableView.rx.model(at: indexPath) {
                item.edit()
            }
        })

        action.image = #imageLiteral(resourceName: "edit")
        return UISwipeActionsConfiguration(actions: [action])
    }
}

protocol ContainFiles {
    var files: [File] { get set }
}

class DatedDescribedFileContainedPresentation: Presentation {

    let view: UIView = UIView()
    private let tableView = StandardTableView()
    private let navBar: NavigationBarWithBackButton
    private let filesSubject = PublishSubject<[File]>()
    private let disposeBag = DisposeBag()
    private let editButton = UIButton()
    .with(image: #imageLiteral(resourceName: "editIcon"))

    private let item: Named & Dated & Described & ContainFiles & Editable

    init(item: Named & Dated & Described & ContainFiles & Editable , gradient: [UIColor]) {

        tableView.tableHeaderView = HeaderView(item: item, hasFiles: !item.files.isEmpty)
        tableView.separatorStyle = .none
        self.item = item

        navBar = NavigationBarWithBackButton(title: item.name)
                .with(gradient: gradient)
                .with(rightInactiveButton: editButton)

        view.addSubviews([tableView, navBar])

        navBar.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(120)
        }

        tableView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(navBar.snp.bottom)
        }

        let dataSource = RxTableViewSectionedReloadDataSource<StandardSectionModel<File>>(configureCell: {  ds, tv, ip, item in
            return tv.dequeueReusableCellOfType(FileCell.self, for: ip).configured(item: item)
        })
        
        Observable.from([item.files])
                .map { [StandardSectionModel<File>(items: $0)] }
                .bind(to: tableView.rx.items(dataSource: dataSource))
                .disposed(by: disposeBag)

        editButton.rx.tap.subscribe(onNext: {
            item.edit()
        }).disposed(by: disposeBag)

    }

    func willAppear() {
        if let headerView = tableView.tableHeaderView {

            let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            var headerFrame = headerView.frame

            //Comparison necessary to avoid infinite loop
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
            }
        }
    }

    func wantsToPerform() -> Observable<Transition> {
        return Observable.merge([
            navBar.wantsToPerform(),
            item.wantsToPerform()
        ])
    }

    class HeaderView: UIView {
        init(item: Dated & Described, hasFiles: Bool ) {

            super.init(frame: .zero)

            let formatter = DateFormatter()

            formatter.dateFormat = "dd MMMM YYYY"

            let dateLabel = UILabel()
            .with(font: .medCardCell)
                    .with(textColor: .mainText)
            .with(text: formatter.string(from: item.date))

            let descriptionLabel = UILabel()
            .with(font: .subtitleText13)
            .with(textColor: .blueGrey)
            .with(text: item.description)
            .with(numberOfLines: 0)

            let filesLaabel = UILabel()
            .with(font: .medium13)
            .with(text: "Файлы")
            .with(textColor: .mainText)

            if !hasFiles {
                filesLaabel.isHidden = true
            }

            addSubviews([dateLabel, descriptionLabel, filesLaabel])

            dateLabel.snp.makeConstraints {
                $0.top.leading.equalToSuperview().offset(16)
                $0.trailing.equalToSuperview().inset(16)
            }

            descriptionLabel.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(16)
                $0.trailing.equalToSuperview().inset(16)
                $0.top.equalTo(dateLabel.snp.bottom).offset(12)
            }

            filesLaabel.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(16)
                $0.top.equalTo(descriptionLabel.snp.bottom).offset(20)
                $0.bottom.equalToSuperview().inset(8)
            }

        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("Storyboards are deprecated!")
        }
    }
}


class FileCell: UITableViewCell {

    private var nameLabel = UILabel()
    .with(font: .light12)
    .with(textColor: .blueGrey)
    private var sizeLabel = UILabel()
    .with(font: .light12)
    .with(textColor: .blueGrey)
    private var icon = UIImageView(image: #imageLiteral(resourceName: "jpg1"))
    .with(contentMode: .scaleAspectFit)

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let containerView = UIView()
        .with(borderWidth: 1, borderColor: .shadow)
        .with(roundedEdges: 4)

        containerView.addSubviews([icon, nameLabel, sizeLabel])

        addSubview(containerView)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
            $0.height.equalTo(58)
        }

        icon.snp.makeConstraints {
            $0.width.equalTo(22)
            $0.height.equalTo(26)
            $0.top.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().inset(16)
        }

        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(icon.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(icon)
        }

        sizeLabel.snp.makeConstraints {
            $0.leading.width.equalTo(nameLabel)
            $0.lastBaseline.equalTo(icon.snp.bottom)
        }

    }

    func configured(item: File) -> Self {
        nameLabel.text = item.name
        sizeLabel.text = item.size

        return self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are deprecated")
    }
}