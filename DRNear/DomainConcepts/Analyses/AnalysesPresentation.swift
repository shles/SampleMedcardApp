//
// Created by Артмеий Шлесберг on 16/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SnapKit
import RxCocoa
import RxDataSources

typealias DatedListApplicable = Dated & Named & Described & SystemRelated & Deletable & Editable

protocol DatedListRepresentable {
    func toListRepresentable() -> Observable<[DatedListApplicable]>
}

class DDNListPresentation: Presentation {
    var view: UIView = UIView()

    private let tableView = StandardTableView()
    private let navBar: NavigationBarWithBackButton

    private let transitionSubject = PublishSubject<Transition>()
    private let itemsSubject = ReplaySubject<[DatedListApplicable]>.create(bufferSize: 1)
    private let refreshSubject = PublishSubject<Void>()
    private let disposeBag = DisposeBag()

    private let items: Refreshable<[DatedListApplicable]>
    private let leadingTo: () -> (UIViewController)

    init(items: DatedListRepresentable, title: String, gradient: [UIColor], leadingTo: @escaping () -> (UIViewController)) {

        self.leadingTo = leadingTo
        self.items = Refreshable(origin: items.toListRepresentable(), refreshOn: refreshSubject)

        navBar = NavigationBarWithBackButton(title: title)
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

        self.items.asObservable().bind(to: itemsSubject).disposed(by: disposeBag)

        let dataSource = RxTableViewSectionedReloadDataSource<StandardSectionModel<DatedListApplicable>>(
                configureCell: { _, tv, ip, habit in
                    return tv.dequeueReusableCellOfType(DatedDescribedCell.self, for: ip).configured(item: habit)
                })

        itemsSubject.asObservable()
                .map { [StandardSectionModel(items: $0)] }
                .bind(to: tableView.rx.items(dataSource: dataSource))
                .disposed(by: disposeBag)

    }

    func willAppear() {
        refreshSubject.onNext(())
    }

    func wantsToPerform() -> Observable<Transition> {
        return Observable.never()
    }
}