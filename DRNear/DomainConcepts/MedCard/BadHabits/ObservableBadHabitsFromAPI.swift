//
// Created by Артмеий Шлесберг on 08/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Alamofire
import Foundation
import RxSwift
import SwiftyJSON

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

class RefreshableBadHabits: ObservableBadHabits {

    private var origin: ObservableBadHabits
    private var refreshOn: Observable<Void>

    init(origin: ObservableBadHabits, refreshOn: Observable<Void>) {
        self.origin = origin
        self.refreshOn = refreshOn
    }
    func asObservable() -> Observable<[BadHabit]> {
        return refreshOn.startWith(()).flatMapLatest { [unowned self] in self.origin.asObservable() }
    }
}

class ObservableBadHabitsFromAPI: ObservableBadHabits, ObservableType {

    typealias E = [BadHabit]
    private let token: Token
    private let request: Request

    init(token: Token) throws {

        request = try AuthorizedRequest(
                path: "/eco-emc/api/medical-records/952/bad-habits",
                method: .get,
                token: token,
                parameters: ["type": "detached"],
                encoding: URLEncoding.default
        )
        self.token = token
    }

    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == [BadHabit] {
        return request.make()
                .map { json in

                    json.arrayValue.map { (json: JSON) in
                        BadHabitFrom(
                                name: json["name"].string  ?? "",
                                id: json["code"].string ?? "",
                                token: self.token
                        )
                    }
                }.subscribe(observer)
    }
}
