//
//  SimpleAllergy.swift
//  DRNear
//
//  Created by Igor Shmakov on 17/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

class SimpleAllergy: Allergy {
    
    var name: String = "Аллергия на пыльцу"
    var identification: String = "123"
    
    var isSelected = Variable<Bool>(true)
    
    func select() {
        isSelected.value = !isSelected.value
    }
    
}

