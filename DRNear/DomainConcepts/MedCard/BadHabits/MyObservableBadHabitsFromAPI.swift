//
// Created by Артмеий Шлесберг on 08/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Alamofire
import Foundation
import RxSwift
import SwiftyJSON
import SnapKit

class MyObservableBadHabitsFromAPI: ObservableBadHabits, ObservableType {

    typealias E = [BadHabit]

    private let token: Token

    init(token: Token) {

        self.token = token
    }

    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == [BadHabit] {

        if let request = try? AuthorizedRequest(
                path: "/eco-emc/api/my/bad-habits",
                method: .get,
                token: token,
                encoding: URLEncoding.default
        ) {
            return request.make()
                    .map { json in

                        json.arrayValue.map { (json: JSON) in
                            MyBadHabitFrom(
                                    name: json["name"].string ?? "",
                                    id: json["code"].string ?? "",
                                    token: self.token
                            )
                        }
                    }.share(replay: 1).subscribe(observer)
        } else {
            return Observable.error(RequestError()).subscribe(observer)
        }
    }
}

class MyBadHabitFrom: BadHabit, Deletable {

    private(set) var name: String = ""
    private(set) var identification: String = ""
    private(set) var isSelected: Variable<Bool> = Variable(true)

    private let deletionSubject = PublishSubject<Transition>()

    private let token: Token

    private let disposeBag = DisposeBag()

    init(name: String, id: String, token: Token) {
        self.name = name
        self.identification = id
        self.token = token
    }

    func select() {

    }

    func delete() {
        deletionSubject.onNext(PresentTransition {
            ViewController(
                    presentation: DeletionPresentation(
                            title: "Вы точно хотите удалить привычку \"\(self.name)\"?",
                            onAccept: { [unowned self] in
                                if let request = try? AuthorizedRequest(
                                        path: "/eco-emc/api/my/bad-habits",
                                        method: .delete,
                                        token: self.token,
                                        parameters: [self.identification].asParameters(),
                                        encoding: ArrayEncoding()
                                ) {

                                    request.make().subscribe(onNext: {_ in

                                    }).disposed(by: self.disposeBag)
                                }
                            }
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
        MyBadHabitFrom(name: "aaa", id: "a", token: TokenFromString(string: "")),
        MyBadHabitFrom(name: "bbb", id: "b", token: TokenFromString(string: "")),
        MyBadHabitFrom(name: "ccc", id: "c", token: TokenFromString(string: ""))
    ]

    func asObservable() -> Observable<[BadHabit]> {
        return Observable.just(array)
    }

}
