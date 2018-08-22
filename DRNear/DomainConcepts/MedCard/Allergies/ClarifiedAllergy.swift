//
// Created by Артмеий Шлесберг on 22/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

class ClarifiedAllergy: Allergy {

    private var origin: Allergy
    let clarification: String

    init(origin: Allergy, clarification: String) {
        self.origin = origin
        self.clarification = clarification
    }

    var name: String {
        return origin.name
    }
    var identification: String {
        return origin.identification
    }
    var isSelected: Variable<Bool> {
        return origin.isSelected
    }
    var category: AllergyCategory? {
        return origin.category
    }
    var status: AllergyIntoleranceStatus? {
        return origin.status
    }
    var digitalMedicalRecordId: Int {
        return origin.digitalMedicalRecordId
    }

    func select() {
        origin.select()
    }
}
