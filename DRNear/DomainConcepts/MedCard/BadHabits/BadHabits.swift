//
// Created by Артмеий Шлесберг on 06/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

typealias ListApplicable = Named & Selectable & Identified

protocol ListRepresentable {
    func toListApplicable() -> Observable<[ListApplicable]>
}

protocol ObservableBadHabits: ListRepresentable {
    func asObservable() -> Observable<[BadHabit]>
}

extension ObservableBadHabits {
    func toListApplicable() -> Observable<[ListApplicable]> {
        return asObservable().map { $0.map { $0 as ListApplicable } }
    }
}

class SimpleObservableBadHabits: ObservableBadHabits, ObservableType, Searchable {

    typealias E = [BadHabit]

    private let habits = [
        SimpleBadHabit(),
        SimpleBadHabit(),
        SimpleBadHabit(),
        SimpleBadHabit(),
        SimpleBadHabit(),
        SimpleBadHabit()
    ]

    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == [BadHabit] {
        return Observable.just(habits).subscribe(observer)
    }

    func search(string: String) {

    }
}
