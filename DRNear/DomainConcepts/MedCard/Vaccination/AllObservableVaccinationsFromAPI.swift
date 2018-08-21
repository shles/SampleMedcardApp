//
//  AllObservableVaccinationsFromAPI.swift
//  DRNear
//
//  Created by Igor Shmakov on 17/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Alamofire
import Foundation
import RxSwift
import SwiftyJSON

class AllObservableVaccinationsFromAPI: ObservableVaccinations, ObservableType, Searchable {
    
    typealias E = [Vaccination]
    private let token: Token
    private let searchSubject = PublishSubject<String>()
    
    init(token: Token) throws {
        self.token = token
    }
    
    //TODO: somewhere here is a cause of disposing when error occures. Needed to be recoverable or not emitting error
    
    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == [Vaccination] {
        
        return searchSubject.startWith("").debug().map { [unowned self] name in
            
            try AuthorizedRequest(
                path: "/eco-emc/api/my/vaccinations",
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
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                return json.arrayValue.map { (json: JSON) in
                    VaccinationFrom(
                        name: json["name"]["name"].string ?? "",
                        id: json["id"].string ?? "",
                        code: json["name"]["code"].string ?? "",
                        date: formatter.date(from: json["date"].string ?? "") ?? Date(),
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
