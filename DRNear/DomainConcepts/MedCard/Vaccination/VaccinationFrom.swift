//
//  VaccinationFrom.swift
//  DRNear
//
//  Created by Igor Shmakov on 17/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON

class VaccinationFrom: Vaccination {
    
    init(name: String, id: String, code: String, date: Date, selected: Bool = false, token: Token) {
        self.name = name
        self.code = code
        self.date = date
        self.identification = id
        self.isSelected.value = selected
        self.token = token
    }
    
    var date = Date()
    var name: String = ""
    var code: String = ""
    var identification: String = ""
    var isSelected: Variable<Bool> = Variable(false)
    private var token: Token
    
    func select() {
        isSelected.value = !isSelected.value
    }
}


