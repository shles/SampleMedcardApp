//
//  MyObservableConsultationsFromAPI.swift
//  DRNear
//
//  Created by Igor Shmakov on 18/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Alamofire
import Foundation
import RxSwift
import SnapKit
import SwiftyJSON

class MyObservableConsultationsFromAPI: ObservableConsultations, ObservableType {

    typealias E = [Consultation]

    private let token: Token
    private let request: Request

    init(token: Token) throws {

        request = try AuthorizedRequest(
            path: "/eco-emc/api/my/consultations",
            method: .get,
            token: token,
            encoding: URLEncoding.default
        )
        self.token = token
    }

    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == [Consultation] {
        return request.make()
            .map { json in
                return json.arrayValue.map { (json: JSON) in
                    MyConsultationFrom(name: json["name"].string ?? "",
                                       id: json["id"].string ?? "",
                                       date: Date.from(fullString: json["date"].string ?? "") ?? Date(),
                                       description: json["recommendations"].string ?? "",
                                       token: self.token)
                }
            }.share(replay: 1).subscribe(observer)
    }
}

class MyConsultationFrom: Consultation, ContainFiles {

    private(set) var name: String = ""
    private(set) var date: Date = Date()
    private(set) var isRelatedToSystem: Bool = false
    private(set) var identification: String = ""
    var files: [File] = []
    
    var description: String = ""
    private let token: Token

    private var deletionSubject = PublishSubject<Void>()
    private var interactionSubject = PublishSubject<Void>()
    private var editionSubject = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    private var transitionSubject = PublishSubject<Transition>()

    init(name: String, id: String, date: Date, description: String, token: Token, files: [File] = [] ) {
        self.name = name
        self.identification = id
        self.date = date
        self.description = description
        self.token = token
        self.files = files
    }

    func create() {
        
        if let request = try? AuthorizedRequest(
            path: "/eco-emc/api/my/consultations",
            method: .post,
            token: self.token,
            parameters: self.json,
            encoding: JSONEncoding.default
        ) {

            request.make().map { _ in PopTransition()}.bind(to: transitionSubject)
        }
    }
    
    func delete() {
        deletionSubject.onNext(())
    }

    func wantsToPerform() -> Observable<Transition> {
        return Observable.merge([
            deletionSubject.map { [unowned self] _ in
                PresentTransition(leadingTo: {
                    ViewController(
                        presentation: DeletionPresentation(
                            title: "Вы уверены, что хотите консультацию \"\(self.name)\"?",
                            onAccept: { [unowned self] in
                                if let request = try? AuthorizedRequest(
                                    path: "/eco-emc/api/consultations/\(self.identification)",
                                    method: .delete,
                                    token: self.token
                                    ) {
                                    
                                    return request.make().map {_ in }
                                }
                                
                                return Observable.just(())
                            }
                        )
                    )
                }
                )
            },
            interactionSubject.debug("interacted with \(self.description)").map { [unowned self] _ in
                PushTransition(leadingTo: {
                    ViewController(presentation: DatedDescribedFileContainedPresentation(item: self, gradient: [.darkSkyBlue, .tiffanyBlue]))
                })
            },
//             Need presentation
            editionSubject.map { [unowned self] _ in
                PushTransition(leadingTo: {
                    ViewController(presentation: ConsultationEditingPresentation(
                        consultation: self,
                        onSave: { [unowned self] in
                            if let request = try? AuthorizedRequest(
                                path: "/eco-emc/api/consultations/\(self.identification)",
                                method: .put,
                                token: self.token,
                                parameters: self.json,
                                encoding: JSONEncoding.default
                                ) {

                                return request.make().map {_ in }
                            }

                            return Observable.just(())
                    }))
                })
            },
        transitionSubject
        ])
    }

    func edit() {
        editionSubject.onNext(())
    }

    func interact() {
        interactionSubject.onNext(())
    }

    var json: [String: Any]  {
//        "date": "2018-08-23T13:33:02.736Z",
//        "diagnoses": [
//            {
//                "comments": "мой старый диагноз",
//                "diagnoseStatus": {
//                "code": "01"
//            },
//                "name": {
//                "code": "01"
//            },
//                "files": [
//                {
//                    "fuid": "string",
//                }
//            ],
//                "value": "каое то значение",
//                "verificationStatus": {
//                "code": "01"
//            }
//            }
//        ],
//        "name": "еженедельная консультация"
//    }

        return [
            "date": date.fullString,
            "diagnoses": [[
                "comments": "мой старый диагноз",
                "diagnoseStatus": ["code": "01"],
                "name": ["code": "01"],
                "files": files.map { ["fuid": $0.identification]},
                "value": "каое то значение",
                "verificationStatus": ["code": "01"]
            ]],
            "name": name
        ]
    }
}

class ObservableSimpleMyConsultations: ObservableConsultations {

    private let array = [
        MyConsultationFrom(name: "aaa", id: "a", date: Date(), description: "Вы больны", token: TokenFromString(string: "")),
        MyConsultationFrom(name: "bbb", id: "b", date: Date(), description: "Вы больны", token: TokenFromString(string: "")),
        MyConsultationFrom(name: "ccc", id: "c", date: Date(), description: "Вы больны", token: TokenFromString(string: ""))
    ]

    func asObservable() -> Observable<[Consultation]> {
        return Observable.just(array)
    }

}
