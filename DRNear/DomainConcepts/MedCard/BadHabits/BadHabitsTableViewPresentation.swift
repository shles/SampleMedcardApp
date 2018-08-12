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

    let habits: ObservableBadHabits

    private let refreshSubject = PublishSubject<Void>()

    init(observableHabits: ObservableBadHabits) {

        self.habits = RefreshableBadHabits(origin: observableHabits, refreshOn: refreshSubject)

        view.addSubviews([tableView])

        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()

        }

        let dataSource = RxTableViewSectionedReloadDataSource<StandardSectionModel<BadHabitApplicableToTableViewCell>>(
                configureCell: { _, tv, ip, habit in
                    let cell = tv.dequeueReusableCellOfType(SimpleTickedCell.self, for: ip)
                    habit.apply(target: cell)
                    return cell
                })

        self.habits.asObservable().debug()
            .catchErrorJustReturn([])
            .map { $0.map { BadHabitApplicableToTableViewCell(origin: $0) } }
            .map { [StandardSectionModel(items: $0)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(BadHabit.self).subscribe(onNext: { habit in
            habit.select()
        }).disposed(by: disposeBag)

    }

    func willAppear() {
        refreshSubject.onNext(())
    }

    func wantsToPerform() -> Observable<Transition> {
        return Observable.never()
    }
}
