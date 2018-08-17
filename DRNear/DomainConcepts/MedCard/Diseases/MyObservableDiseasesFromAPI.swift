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
import SwiftyJSON
import SnapKit

class MyObservableDiseasesFromAPI: ObservableDiseases, ObservableType {
    
    typealias E = [Disease]
    
    private let token: Token
    private let request: Request
    
    init(token: Token) throws {
        
        request = try AuthorizedRequest(
            path: "/eco-emc/api/my/diseases",
            method: .get,
            token: token,
            encoding: URLEncoding.default
        )
        self.token = token
    }
    
    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == [Disease] {
        return request.make()
            .map { json in
                
                json.arrayValue.map { (json: JSON) in
                    MyDiseaseFrom(
                        name: json["name"].string  ?? "",
                        id: json["code"].string ?? "",
                        token: self.token
                    )
                }
            }.share(replay: 1).subscribe(observer)
    }
}

class MyDiseaseFrom: Disease, Deletable {
    
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
                    title: "Вы точно хотите удалить заболевание \"\(self.name)\"?",
                    onAccept: { [unowned self] in
                        if let request = try? AuthorizedRequest(
                            path: "/eco-emc/api/my/diseases",
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

class ObservableSimpleMyDiseases: ObservableDiseases {
    
    private let array = [
        MyDiseaseFrom(name: "aaa", id: "a", token: TokenFromString(string: "")),
        MyDiseaseFrom(name: "bbb", id: "b", token: TokenFromString(string: "")),
        MyDiseaseFrom(name: "ccc", id: "c", token: TokenFromString(string: ""))
    ]
    
    func asObservable() -> Observable<[Disease]> {
        return Observable.just(array)
    }
    
}

