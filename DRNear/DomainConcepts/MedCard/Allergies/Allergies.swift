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

