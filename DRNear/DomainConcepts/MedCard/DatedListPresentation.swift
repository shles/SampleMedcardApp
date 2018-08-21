//
// ?Created by Артмеий Шлесберг on 16/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SnapKit
import RxCocoa
import RxDataSources

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

    private let items: Refreshable<[DatedListApplicable]>
    private let leadingTo: () -> (UIViewController)

    private var itemsTransitionsDisposeBag = DisposeBag()

    init(items: DatedListRepresentable, title: String, gradient: [UIColor], leadingTo: @escaping () -> (UIViewController)) {

        self.leadingTo = leadingTo
        self.items = Refreshable(origin: items.toListRepresentable(), refreshOn: refreshSubject.skip(1))

        navBar = NavigationBarWithBackButton(title: title)
                .with(gradient: gradient)

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

        self.items.asObservable().bind(to: itemsSubject).disposed(by: disposeBag)

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

        //TODO: maybe develop new object6 that subscribes transitionsubject inside
        itemsSubject.asObservable()
                .catchErrorJustReturn([])
        .subscribe(onNext: { [unowned self] in
            self.itemsTransitionsDisposeBag = DisposeBag()
            Observable.merge($0.map { $0.wantsToPerform() }).subscribe(onNext: {
                self.transitionSubject.onNext($0)
            }).disposed(by: self.itemsTransitionsDisposeBag)
        }).disposed(by: disposeBag)
        
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
    var files: [File] { get }
}

class DatedDescribedFileContainedPresentation: Presentation {

    let view: UIView = UIView()
    private let tableView = StandardTableView()
    private let navBar: NavigationBarWithBackButton

    init(item: Named & Dated & Described & ContainFiles) {

        tableView.tableHeaderView = HeaderView(item: item)

        navBar = NavigationBarWithBackButton(title: item.name)
                .with(gradient: [.darkSkyBlue, .tiffanyBlue])

        view.addSubviews([tableView, navBar])

        navBar.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(120)
        }

        tableView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(navBar.snp.bottom)
        }

        item.files
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
        return Observable.never()
    }

    class HeaderView: UIView {
        init(item: Dated & Described ) {

            super.init(frame: .zero)

            let formatter = DateFormatter()

            formatter.dateFormat = "dd MMMM YYYY"

            let dateLabel = UILabel()
            .with(font: .medCardCell)
                    .with(textColor: .mainText)
            .with(text: formatter.string(from: item.date))

            let descriptionLabel = UILabel()
            .with(font: .subtitleText13)
            .with(textColor: .blueyGrey)
            .with(text: item.description)
            .with(numberOfLines: 0)

            let filesLaabel = UILabel()
            .with(font: .medium13)
            .with(text: "Файлы")
            .with(textColor: .mainText)

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
