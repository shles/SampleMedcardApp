//
// Created by Артмеий Шлесберг on 16/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

protocol MedicalTest: Named, Dated, Described, SystemRelated, Editable, Deletable, Identified, Interactive, Serializable {

}

protocol ObservableMedicalTests: DatedListRepresentable {

  func asObservable() -> Observable<[MedicalTest]>

}

extension ObservableMedicalTests {
    func toListRepresentable() -> Observable<[DatedListApplicable]> {
        return asObservable().map { $0.map { $0 as DatedListApplicable } }
    }
}
