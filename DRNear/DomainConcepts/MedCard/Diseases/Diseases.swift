//
//  Diseases.swift
//  DRNear
//
//  Created by Igor Shmakov on 17/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

protocol Diseases: ListApplicable {
    
}

protocol ObservableDiseases: ListRepresentable {
    func asObservable() -> Observable<[Disease]>
}

extension ObservableDiseases {
    func toListApplicable() -> Observable<[ListApplicable]> {
        return asObservable().map { $0.map { $0 as ListApplicable } }
    }
}

class SimpleObservableDiseases: ObservableDiseases, ObservableType, Searchable {
    
    typealias E = [Disease]
    
    private let diseases = [
        SimpleDisease(),
        SimpleDisease(),
        SimpleDisease(),
        SimpleDisease(),
        SimpleDisease(),
        SimpleDisease()
    ]
    
    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == [Disease] {
        return Observable.just(diseases).subscribe(observer)
    }
    
    func search(string: String) {
        
    }
}
