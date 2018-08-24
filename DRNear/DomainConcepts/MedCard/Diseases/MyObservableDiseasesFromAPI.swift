//
//  MyObservableDiseasesFromAPI.swift
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

class MyObservableDiseasesFromAPI: ObservableDiseases, ObservableType {

    typealias E = [Disease]

    private let token: Token

    init(token: Token) {
        self.token = token
    }

    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == [Disease] {

        if let request = try? AuthorizedRequest(
                   path: "/eco-emc/api/my/diagnoses",
                   method: .get,
                   token: token,
                   encoding: URLEncoding.default
           ) {
            return request.make()
                    .map { json in

                        json.arrayValue.map { (json: JSON) in
                            MyDiseaseFrom(
                                    name: json["name"]["name"].string ?? "",
                                    id: json["name"]["code"].string ?? "",
                                    code: json["name"]["code"].string ?? "",
                                    token: self.token
                            )
                        }
                    }.share(replay: 1).subscribe(observer)
        } else {
            return  Observable.error(RequestError()).subscribe(observer)
        }
    }
}

class MyDiseaseFrom: Disease, Deletable {

    private(set) var name: String = ""
    private(set) var code: String = ""
    private(set) var identification: String = ""
    private(set) var isSelected: Variable<Bool> = Variable(true)

    private let deletionSubject = PublishSubject<Transition>()

    private let token: Token

    private let disposeBag = DisposeBag()

    init(name: String, id: String, code: String, token: Token) {
        self.name = name
        self.code = code
        self.identification = id
        self.token = token
    }

    func select() {

    }

    func delete() {
        deletionSubject.onNext(PresentTransition {
            ViewController(
                presentation: DeletionPresentation(
                    title: "Вы точно хотите удалить заболевание \"\(self.name)\"?",
                    onAccept: { [unowned self] in
                        if let request = try? AuthorizedRequest(
                            path: "/eco-emc/api/my/diagnoses",
                            method: .put,
                            token: self.token,
                            parameters: [self.identification].asParameters(),
                            encoding: ArrayEncoding()
                            ) {

                            return request.make().map { _ in }
                        }
                        return Observable.just(())
                    }
                )
            )
        })
    }

    func wantsToPerform() -> Observable<Transition> {
        return deletionSubject.asObservable().debug()
    }
}

class ObservableSimpleMyDiseases: ObservableDiseases {

    private let array = [
        MyDiseaseFrom(name: "aaa", id: "a", code: "", token: TokenFromString(string: "")),
        MyDiseaseFrom(name: "bbb", id: "b", code: "", token: TokenFromString(string: "")),
        MyDiseaseFrom(name: "ccc", id: "c", code: "", token: TokenFromString(string: ""))
    ]

    func asObservable() -> Observable<[Disease]> {
        return Observable.just(array)
    }

}
