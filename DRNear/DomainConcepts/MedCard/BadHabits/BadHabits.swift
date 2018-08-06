//
// Created by Артмеий Шлесберг on 06/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

protocol ObservableBadHabits {
    func asObservable() -> Observable<[BadHabit]>
}

class SimpleObservableBadHabits: ObservableBadHabits {

    private let habits = [
        SimpleBadHabit(),
        SimpleBadHabit(),
        SimpleBadHabit(),
        SimpleBadHabit(),
        SimpleBadHabit(),
        SimpleBadHabit()
    ]

    func asObservable() -> Observable<[BadHabit]> {
        return Observable.just(habits)
    }
}