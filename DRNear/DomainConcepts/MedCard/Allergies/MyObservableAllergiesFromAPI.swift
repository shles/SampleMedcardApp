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
import SwiftyJSON
import SnapKit

class MyObservableAllergiesFromAPI: ObservableAllergies, ObservableType {
    
    typealias E = [Allergy]
    
    private let token: Token
    private let request: Request
    
    init(token: Token) throws {
        
        request = try AuthorizedRequest(
            path: "/eco-emc/api/my/allergies",
            method: .get,
            token: token,
            encoding: URLEncoding.default
        )
        self.token = token
    }
    
    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == [Allergy] {
        return request.make()
            .map { json in
                
                json.arrayValue.map { (json: JSON) in
                    MyAllergyFrom(
                        name: json["name"].string  ?? "",
                        id: json["code"].string ?? "",
                        token: self.token
                    )
                }
            }.share(replay: 1).subscribe(observer)
    }
}

class MyAllergyFrom: Allergy, Deletable {
    
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
                    title: "Вы точно хотите удалить аллергию \"\(self.name)\"?",
                    onAccept: { [unowned self] in
                        if let request = try? AuthorizedRequest(
                            path: "/eco-emc/api/my/allergies",
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

class ObservableSimpleMyAllergies: ObservableAllergies {
    
    private let array = [
        MyAllergyFrom(name: "aaa", id: "a", token: TokenFromString(string: "")),
        MyAllergyFrom(name: "bbb", id: "b", token: TokenFromString(string: "")),
        MyAllergyFrom(name: "ccc", id: "c", token: TokenFromString(string: ""))
    ]
    
    func asObservable() -> Observable<[Allergy]> {
        return Observable.just(array)
    }
    
}
