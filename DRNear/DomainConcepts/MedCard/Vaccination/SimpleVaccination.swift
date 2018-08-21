//
//  SimpleVaccination.swift
//  DRNear
//
//  Created by Igor Shmakov on 17/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

class SimpleVaccination: Vaccination {
    
    var date: Date = Date()
    var name: String = "Прививка от хитрости"
    var identification: String = "123"
    
    var isSelected = Variable<Bool>(true)
    
    func select() {
        isSelected.value = !isSelected.value
    }
    
}
