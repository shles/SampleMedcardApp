//
// Created by Артмеий Шлесберг on 08/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Alamofire
import Foundation
import RxSwift
import SwiftyJSON

class BadHabitFrom: BadHabit {

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
