//
//  DiseaseFrom.swift
//  DRNear
//
//  Created by Igor Shmakov on 17/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON

class DiseaseFrom: Disease {
    
    init(name: String, id: String, selected: Bool = false, token: Token) {
        self.name = name
        self.identification = id
        self.isSelected.value = selected
        self.token = token
    }
    
    var name: String = ""
    var identification: String = ""
    var isSelected: Variable<Bool> = Variable(false)
    private var token: Token
    
    func select() {
        isSelected.value = !isSelected.value
    }
}


