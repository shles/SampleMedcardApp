//
// Created by Артмеий Шлесберг on 14/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

class Refreshable<T> {

    private var origin: Observable<T>
    private var refreshOn: Observable<Void>

    init<O: Observable<T>>(origin: O, refreshOn: Observable<Void>) where O.E == T {
        self.origin = origin
        self.refreshOn = refreshOn
    }

    func asObservable() -> Observable<T> {
        return refreshOn.startWith(()).flatMapLatest { [unowned self] _ in self.origin.asObservable() }
    }
}