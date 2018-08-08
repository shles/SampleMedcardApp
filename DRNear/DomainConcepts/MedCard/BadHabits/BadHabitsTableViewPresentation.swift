//
// Created by Артмеий Шлесберг on 06/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit
import RxDataSources

class BadHabitsTableViewPresentation: Presentation {

    var view: UIView = UIView()

    private var tableView = StandardTableView()
    private let disposeBag = DisposeBag()

    private let habits: ObservableBadHabits
    private let navBar = NavigationBarWithBackButton(title: "Вредные привычки")
        .with(gradient: [.wheatTwo, .rosa])
        .with(rightInactiveButton: UIButton().with(image: #imageLiteral(resourceName: "addIcon")))

    init(observableHabits: ObservableBadHabits) {

        self.habits = observableHabits

        view.addSubviews([navBar, tableView])

        navBar.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(120)
        }
        tableView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(navBar.snp.bottom)
        }

        let dataSource = RxTableViewSectionedReloadDataSource<StandardSectionModel<BadHabitApplicableToTableViewCell>>(
                configureCell: { ds, tv, ip, habit in
                    let cell = tv.dequeueReusableCellOfType(SimpleTickedCell.self, for: ip)
                    habit.apply(target: cell)
                    return cell
                })

        habits.asObservable()
            .map { $0.map { BadHabitApplicableToTableViewCell(origin: $0) } }
            .map { [StandardSectionModel(items: $0)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

    }

    func wantsToPush() -> Observable<UIViewController> {
        return Observable<UIViewController>.never()
    }

    func wantsToPresent() -> Observable<UIViewController> {
        return Observable<UIViewController>.never()
    }

    func wantsToPop() -> Observable<Void> {
        return navBar.wantsToPop()
    }

    func wantsToBeDismissed() -> Observable<Void> {
        return Observable<Void>.never()
    }

    func willAppear() {

    }
}

