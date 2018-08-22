//
//  Allergy.swift
//  DRNear
//
//  Created by Igor Shmakov on 17/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

protocol Allergy: Named, Identified, Selectable {

    var category: AllergyCategory? { get }
    var status: AllergyIntoleranceStatus? { get }
    var digitalMedicalRecordId: Int { get }
    var name: String { get }
    var identification: String { get }
    var isSelected: Variable<Bool> { get }
}
