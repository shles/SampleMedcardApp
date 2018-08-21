//
//  AllObservableAllergiesFromAPI.swift
//  DRNear
//
//  Created by Igor Shmakov on 17/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Alamofire
import Foundation
import RxSwift
import SwiftyJSON

class AllObservableAllergiesFromAPI: ObservableAllergies, ObservableType, Searchable {
    
    typealias E = [Allergy]
    private let token: Token
    private let searchSubject = PublishSubject<String>()
    
    init(token: Token) throws {
        self.token = token
    }
    
    //TODO: somewhere here is a cause of disposing when error occures. Needed to be recoverable or not emitting error
    
    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == [Allergy] {
        
        return searchSubject.startWith("").debug().map { [unowned self] name in
            
            try AuthorizedRequest(
                path: "/eco-emc/api/my/allergies",
                method: .get,
                token: self.token,
                parameters: [
                    "type": "detached",
                    "name.like": name
                ],
                encoding: URLEncoding.default
            )
            }.flatMap {
                $0.make()
            }.map { json in
                
                json.arrayValue.map { (json: JSON) in
                    
                    var category: AllergyCategory?
                    var status: AllergyIntoleranceStatus?
  
                    if json["category"].exists() {
                        category = AllergyCategory(code: json["category"]["code"].string ?? "", name: json["category"]["name"].string ?? "")
                    }
                    
                    if json["status"].exists() {
                        status = AllergyIntoleranceStatus(code: json["status"]["code"].string ?? "", name: json["status"]["name"].string ?? "")
                    }
                    
                    return AllergyFrom(
                        clarification: json["clarification"].string ?? "",
                        id: json["id"].string ?? "",
                        digitalMedicalRecordId: json["digitalMedicalRecordId"].int ?? 0,
                        category: category,
                        status: status,
                        token: self.token
                    )
                }
            }.catchErrorJustReturn([])
            .subscribe(observer)
    }
    
    func search(string: String) {
        searchSubject.onNext(string)
    }
}
