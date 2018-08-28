//
//  MyObservableAnalysesFromAPI.swift
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

class MyObservableMedicalTestsFromAPI: ObservableMedicalTests, ObservableType {

    typealias E = [MedicalTest]

    private let token: Token

    init(token: Token) {
        self.token = token
    }

    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == [MedicalTest] {
        if let request = try?AuthorizedRequest(
                path: "/eco-emc/api/my/analyzes",
                method: .get,
                token: token,
                encoding: URLEncoding.default
        ) {
            return request.make()
                    .map { json in
                        return json.arrayValue.map { (json: JSON) in
                            MyMedicalTestFrom(name: json["name"].string ?? "",
                                    id: json["id"].string ?? "",
                                    date: Date.from(fullString: json["date"].string ?? "") ?? Date(),
                                    description: json["report"].string ?? "",
                                    token: self.token)
                        }
                    }.share(replay: 1).subscribe(observer)
        } else {
            return Observable.error(RequestError()).subscribe(observer)
        }
    }
}

class MyMedicalTestFrom: MedicalTest, ContainFiles {

    private(set) var name: String = ""
    private(set) var date: Date = Date()
    private(set) var isRelatedToSystem: Bool = false
    private(set) var identification: String = ""
    var description: String = ""
    private let token: Token

    private var deletionSubject = PublishSubject<Void>()
    private var interactionSubject = PublishSubject<Void>()
    private var editionSubject = PublishSubject<Void>()

    private let disposeBag = DisposeBag()

    init(name: String, id: String, date: Date, description: String, token: Token) {
        self.name = name
        self.identification = id
        self.date = date
        self.description = description
        self.token = token
    }

    func create() {
        
        if let request = try? AuthorizedRequest(
            path: "/api/my/analyzes",
            method: .post,
            token: self.token,
            parameters: self.json,
            encoding: JSONEncoding.default
        ) {
            
            request.make()
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
                                    title: "Вы уверены, что хотите удалить \"\(self.name)\"?",
                                    onAccept: { [unowned self] in
                                        if let request = try? AuthorizedRequest(
                                                path: "/api/analyzes/\(self.identification)",
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
            editionSubject.map { [unowned self] _ in
                PushTransition(leadingTo: {
                    ViewController(presentation: MedicalTestEditingPresentation(
                        medTest: self,
                        onSave: { [unowned self] in
                            if let request = try? AuthorizedRequest(
                                path: "/api/analyzes/\(self.identification)",
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
            }
        ])
    }

    func edit() {
        editionSubject.onNext(())
    }

    func interact() {
        interactionSubject.onNext(())
    }

    private(set) var files: [File] = []
    var json: [String: Any]  {
        fatalError("JSON not implemented")
    }
}

class ObservableSimpleMyMedicalTests: ObservableMedicalTests {

    private let array = [
        MyMedicalTestFrom(name: "aaa", id: "a", date: Date(), description: "Вы больны", token: TokenFromString(string: "")),
        MyMedicalTestFrom(name: "bbb", id: "b", date: Date(), description: "Вы больны", token: TokenFromString(string: "")),
        MyMedicalTestFrom(name: "ccc", id: "c", date: Date(), description: "Вы больны", token: TokenFromString(string: ""))
    ]

    func asObservable() -> Observable<[MedicalTest]> {
        return Observable.just(array)
    }

}
