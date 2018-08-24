//
//  Vaccinations.swift
//  DRNear
//
//  Created by Igor Shmakov on 17/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

protocol Vaccinations: ListApplicable {

}

protocol ObservableVaccinations: ListRepresentable {
    func asObservable() -> Observable<[Vaccination]>
}

extension ObservableVaccinations {
    func toListApplicable() -> Observable<[ListApplicable]> {
        return asObservable().map { $0.map { $0 as ListApplicable } }
    }
}

class SimpleObservableVaccinations: ObservableVaccinations, ObservableType, Searchable {

    typealias E = [Vaccination]

    private let vaccinations = [
        SimpleVaccination(),
        SimpleVaccination(),
        SimpleVaccination(),
        SimpleVaccination(),
        SimpleVaccination(),
        SimpleVaccination()
    ]

    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == [Vaccination] {
        return Observable.just(vaccinations).subscribe(observer)
    }

    func search(string: String) {

    }
}
