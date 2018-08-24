//
//  MyObservableVaccinationsFromAPI.swift
//  DRNear
//
//  Created by Igor Shmakov on 17/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Alamofire
import Foundation
import RxSwift
import SnapKit
import SwiftyJSON

class MyObservableVaccinationsFromAPI: ObservableVaccinations, ObservableType {

    typealias E = [Vaccination]

    private let token: Token

    init(token: Token) {
        self.token = token
    }

    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == [Vaccination] {
        if let request = try? AuthorizedRequest(
                path: "/eco-emc/api/my/vaccinations",
                method: .get,
                token: token,
                encoding: URLEncoding.default
        ) {
            return request.make()
                    .map { json in
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                        return json.arrayValue.map { (json: JSON) in
                            MyVaccinationFrom(
                                    name: json["name"]["name"].string ?? "",
                                    id: json["name"]["code"].string ?? "",
                                    code: json["name"]["code"].string ?? "",
                                    date: formatter.date(from: json["date"].string ?? "") ?? Date(),
                                    token: self.token
                            )
                        }
                    }.share(replay: 1).subscribe(observer)
        } else {
            return Observable.error(RequestError()).subscribe(observer)
        }
    }
}

class MyVaccinationFrom: Vaccination, Deletable {

    private(set) var date = Date()
    private(set) var name: String = ""
    private(set) var code: String = ""
    private(set) var identification: String = ""
    private(set) var isSelected: Variable<Bool> = Variable(true)

    private let deletionSubject = PublishSubject<Transition>()

    private let token: Token

    private let disposeBag = DisposeBag()

    init(name: String, id: String, code: String, date: Date, token: Token) {
        self.name = name
        self.code = code
        self.date = date
        self.identification = id
        self.token = token
    }

    func select() {

    }

    func delete() {
        deletionSubject.onNext(PresentTransition {
            ViewController(
                presentation: DeletionPresentation(
                    title: "Вы точно хотите удалить прививку \"\(self.name)\"?",
                    onAccept: { [unowned self] in
                        if let request = try? AuthorizedRequest(
                            path: "/eco-emc/api/my/vaccinations",
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

class ObservableSimpleMyVaccinations: ObservableVaccinations {

    private let array = [
        MyVaccinationFrom(name: "aaa", id: "a", code: "", date: Date(), token: TokenFromString(string: "")),
        MyVaccinationFrom(name: "bbb", id: "b", code: "", date: Date(), token: TokenFromString(string: "")),
        MyVaccinationFrom(name: "ccc", id: "c", code: "", date: Date(), token: TokenFromString(string: ""))
    ]

    func asObservable() -> Observable<[Vaccination]> {
        return Observable.just(array)
    }

}
