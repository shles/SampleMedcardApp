//
//  AllergyFrom.swift
//  DRNear
//
//  Created by Igor Shmakov on 17/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON

struct AllergyIntoleranceStatus {
    
    var code: String
    var name: String
}

struct AllergyCategory {
    
    var code: String
    var name: String
}

class AllergyFrom: Allergy {
    
    init(clarification: String,
         id: String,
         digitalMedicalRecordId: Int,
         category: AllergyCategory?,
         status: AllergyIntoleranceStatus?,
         selected: Bool = false,
         token: Token) {
        
        self.name = clarification
        self.identification = id
        self.digitalMedicalRecordId = digitalMedicalRecordId
        self.category = category
        self.status = status
        self.isSelected.value = selected
        self.token = token
    }
    
    var category: AllergyCategory?
    var status: AllergyIntoleranceStatus?
    var digitalMedicalRecordId = 0
    
    var name: String = ""
    var identification: String = ""
    var isSelected: Variable<Bool> = Variable(false)
    
    private var token: Token
    
    func select() {
        isSelected.value = !isSelected.value
    }
}

