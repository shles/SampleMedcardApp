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
import SwiftyJSON
import SnapKit

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
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                return json.arrayValue.map { (json: JSON) in
                    MyConsultationFrom(name: json["name"].string ?? "",
                                       id: json["id"].string ?? "",
                                       date: dateFormatter.date(from: json["date"].string ?? "") ?? Date(),
                                       description: json["recommendations"].string ?? "",
                                       token: self.token)
                }
            }.share(replay: 1).subscribe(observer)
    }
}

class MyConsultationFrom: Consultation {
    
    private(set) var name: String = ""
    private(set) var date: Date = Date()
    private(set) var isRelatedToSystem: Bool = false
    private(set) var identification: String = ""
    var description: String = ""
    private let token: Token
    
    private var deletionSubject = PublishSubject<Transition>()
    private let disposeBag = DisposeBag()
    
    init(name: String, id: String, date: Date, description: String, token: Token) {
        self.name = name
        self.identification = id
        self.date = date
        self.description = description
        self.token = token
    }
    
    func delete() {
        deletionSubject.onNext(PresentTransition {
            ViewController(
                presentation: DeletionPresentation(
                    title: "Вы точно хотите удалить консультацию \"\(self.name)\"?",
                    onAccept: { [unowned self] in
                        if let request = try? AuthorizedRequest(
                            path: "/eco-emc/api/my/consultations",
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
        return deletionSubject.map { [unowned self] _ in
            PresentTransition(
                leadingTo: { ViewController(
                    presentation: DeletionPresentation(
                        title: "Вы уверены, что хотите удалить \"\(self.name)\"?",
                        onAccept: { }
                    )
                    )}
            )
        }
    }
    
    func edit() {
        
    }

    func interact() {

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
