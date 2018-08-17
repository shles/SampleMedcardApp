//
// Created by Артмеий Шлесберг on 15/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

protocol Allergies: ListApplicable {

}

protocol ObservableAllergies: ListRepresentable {
    func asObservable() -> Observable<[Allergy]>
}

extension ObservableAllergies {
    func toListApplicable() -> Observable<[ListApplicable]> {
        return asObservable().map { $0.map { $0 as ListApplicable } }
    }
}

class SimpleObservableAllergies: ObservableAllergies, ObservableType, Searchable {
    
    typealias E = [Allergy]
    
    private let allergies = [
        SimpleAllergy(),
        SimpleAllergy(),
        SimpleAllergy(),
        SimpleAllergy(),
        SimpleAllergy(),
        SimpleAllergy()
    ]
    
    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == [Allergy] {
        return Observable.just(allergies).subscribe(observer)
    }
    
    func search(string: String) {
        
    }
}
