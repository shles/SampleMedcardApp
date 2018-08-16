//
// Created by Артмеий Шлесберг on 08/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Alamofire
import Foundation
import RxSwift
import SwiftyJSON
import SnapKit

class ObservableMyBadHabitsFromAPI: ObservableBadHabits, ObservableType {

    typealias E = [BadHabit]

    private let token: Token
    private let request: Request

    init(token: Token) throws {

        request = try AuthorizedRequest(
                path: "/eco-emc/api/my/bad-habits",
                method: .get,
                token: token,
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
                                selected: true,
                                token: self.token
                        )
                    }
                }.share(replay: 1).subscribe(observer)
    }
}

class MyBadHabitFrom: BadHabit, Deletable {

    private(set) var name: String = ""
    private(set) var identification: String = ""
    private(set) var isSelected: Variable<Bool> = Variable(true)

    private let deletionSubject = PublishSubject<Transition>()

    init(name: String, id: String) {
        self.name = name
        self.identification = id
    }

    func select() {

    }

    func delete() {
        deletionSubject.onNext(PresentTransition {
            ViewController(
                    presentation: DeletionPresentation(
                            title: "Вы точно хотите удалить привычку \"\(self.name)\"?",
                            onAccept: { }
                    )
            )
        })
    }

    func wantsToPerform() -> Observable<Transition> {
        return deletionSubject.asObservable().debug()
    }
}

class ObservableSimpleMyBadHabits: ObservableBadHabits {

    private let array = [
        MyBadHabitFrom(name: "aaa", id: "a"),
        MyBadHabitFrom(name: "bbb", id: "b"),
        MyBadHabitFrom(name: "ccc", id: "c")
    ]

    func asObservable() -> Observable<[BadHabit]> {
        return Observable.just(array)
    }

}
