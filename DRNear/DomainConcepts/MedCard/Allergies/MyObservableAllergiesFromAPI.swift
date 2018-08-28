//
//  MyObservableAllergiesFromAPI.swift
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

class MyObservableAllergiesFromAPI: ObservableAllergies, ObservableType {

    typealias E = [Allergy]

    private let token: Token

    init(token: Token) {

        self.token = token
    }

    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == [Allergy] {

        if let request = try? AuthorizedRequest(
                path: "/eco-emc/api/my/allergies",
                method: .get,
                token: token,
                encoding: URLEncoding.default
        ) {
            return request.make()
                    .map { json in

                        json.arrayValue.map { (json: JSON) in

                            var category: AllergyCategory?
                            var status: AllergyIntoleranceStatus?

                            if json["category"].exists() {
                                category = AllergyCategory(code: json["category"]["code"].string ?? "", name: json["category"]["name"].string ?? "")
                            }

                            if json["status"].exists() {
                                status = AllergyIntoleranceStatus(code: json["status"]["code"].string ?? "", name: json["status"]["name"].string ?? "")
                            }

                            return MyAllergyFrom(
                                    clarification: json["clarification"].string ?? "",
                                    id: json["category"]["code"].string ?? "",
                                    digitalMedicalRecordId: json["digitalMedicalRecordId"].int ?? 0,
                                    category: category,
                                    status: status,
                                    token: self.token
                            )
                        }
                    }.share(replay: 1).subscribe(observer)
        } else {
            return Observable.error(RequestError()).subscribe(observer)
        }
    }
}

class MyAllergyFrom: Allergy, Deletable, Described {

    private(set) var name: String
    private(set) var identification: String
    private(set) var isSelected: Variable<Bool> = Variable(true)
    private(set) var category: AllergyCategory?
    private(set) var status: AllergyIntoleranceStatus?
    private(set) var digitalMedicalRecordId: Int
    private(set) var description: String


    private let deletionSubject = PublishSubject<Transition>()
    private let token: Token
    private let disposeBag = DisposeBag()

    init(clarification: String,
         id: String,
         digitalMedicalRecordId: Int,
         category: AllergyCategory?,
         status: AllergyIntoleranceStatus?,
         token: Token) {

        self.name = category?.name ?? ""
        self.identification = id
        self.digitalMedicalRecordId = digitalMedicalRecordId
        self.category = category
        self.status = status
        self.token = token
        self.description = clarification
    }

    func select() {

    }

    func delete() {
        deletionSubject.onNext(PresentTransition {
            ViewController(
                presentation: DeletionPresentation(
                    title: "Вы точно хотите удалить аллергию \"\(self.name)\"?",
                    onAccept: { [unowned self] in
                        if let request = try? AuthorizedRequest(
                            path: "/eco-emc/api/my/allergies",
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

class ObservableSimpleMyAllergies: ObservableAllergies {

    private let array = [
        MyAllergyFrom(clarification: "aaa", id: "a", digitalMedicalRecordId: 0, category: nil, status: nil, token: TokenFromString(string: "")),
        MyAllergyFrom(clarification: "aaa", id: "a", digitalMedicalRecordId: 0, category: nil, status: nil, token: TokenFromString(string: "")),
        MyAllergyFrom(clarification: "aaa", id: "a", digitalMedicalRecordId: 0, category: nil, status: nil, token: TokenFromString(string: ""))
    ]

    func asObservable() -> Observable<[Allergy]> {
        return Observable.just(array)
    }

}
