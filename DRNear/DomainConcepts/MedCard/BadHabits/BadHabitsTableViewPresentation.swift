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

    let habits: Refreshable<[BadHabit]>

    private let refreshSubject = PublishSubject<Void>()
    private let wantsToPushSubject = PublishSubject<Transition>()

    var selection = PublishSubject<BadHabit>()


    init(observableHabits: ObservableBadHabits) {

        self.habits = Refreshable(origin: observableHabits.asObservable(), refreshOn: refreshSubject)

        view.addSubviews([tableView])

        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()

        }

        let dataSource = RxTableViewSectionedReloadDataSource<StandardSectionModel<BadHabit>>(
                configureCell: { _, tv, ip, habit in
                    let cell = tv.dequeueReusableCellOfType(SimpleTickedCell.self, for: ip)
                    BadHabitApplicableToTableViewCell(origin: habit).apply(target: cell)
                    return cell
                })

        self.habits.asObservable()
            .catchErrorJustReturn([])
//            .map { $0.map { BadHabitApplicableToTableViewCell(origin: $0) } }
            .map { [StandardSectionModel(items: $0)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(BadHabit.self).bind(to: selection).disposed(by: disposeBag)
        
        self.habits.asObservable()
                .catchErrorJustReturn([])
            .flatMap {
                Observable.merge($0.map { ($0 as? MyBadHabitFrom)?.wantsToPerform() ?? Observable.never() })
            }
            .bind(to: wantsToPushSubject)
            .disposed(by: disposeBag)

    }

    func willAppear() {
        refreshSubject.onNext(())
    }

    func wantsToPerform() -> Observable<Transition> {
        return wantsToPushSubject.asObservable().debug()
    }
}
