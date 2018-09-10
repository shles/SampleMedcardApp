//
// Created by Артмеий Шлесберг on 06/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import RxDataSources
import RxSwift
import SnapKit
import UIKit

class BadHabitsTableViewPresentation: Presentation {

    var view: UIView = UIView()

    private var tableView = StandardTableView()
    private let disposeBag = DisposeBag()

    private let habits: Refreshable<[ListApplicable]>

    private let refreshSubject = PublishSubject<Void>()
    private let wantsToPushSubject = PublishSubject<Transition>()
    private let habitsSubject = ReplaySubject<[ListApplicable]>.create(bufferSize: 1)

    private let emptyStateView: UIView

    var selection = PublishSubject<ListApplicable>()

    init(observableHabits: Observable<[ListApplicable]>, tintColor: UIColor, emptyStateView: UIView) {

        self.habits = Refreshable(origin: observableHabits.asObservable().catchErrorJustReturn([]), refreshOn: refreshSubject.skip(1))
        self.emptyStateView = emptyStateView

        habits.asObservable()
                .catchErrorJustReturn([])
                .bind(to: habitsSubject)
                .disposed(by: disposeBag)

        view.addSubviews([emptyStateView, tableView])

        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()

        }
        emptyStateView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().inset(32)
        }

        let dataSource = RxTableViewSectionedReloadDataSource<StandardSectionModel<ListApplicable>>(
                configureCell: { _, tv, ip, habit in
                    return tv.dequeueReusableCellOfType(SimpleTickedCell.self, for: ip).configured(item: habit, tickColor: tintColor)
                })

        habitsSubject.asObservable()
//                .startWith([])
                .do(onNext: { [unowned self] in
                    self.emptyStateView.isHidden = !$0.isEmpty
                    self.tableView.isHidden = $0.isEmpty
                })
            .map { [StandardSectionModel(items: $0)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(ListApplicable.self).bind(to: selection).disposed(by: disposeBag)

        habitsSubject.asObservable()
                .catchErrorJustReturn([])
            .flatMap {
                Observable.merge($0.map {
                    ($0 as? Deletable)?.wantsToPerform() ?? Observable.never()
                })
            }
            .bind(to: wantsToPushSubject)
            .disposed(by: disposeBag)

        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 64, right: 0)

    }

    func willAppear() {
        refreshSubject.onNext(())
    }

    func wantsToPerform() -> Observable<Transition> {
        return wantsToPushSubject.asObservable().debug()
    }
}
