//
// Created by Артмеий Шлесберг on 08/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

class BadHabitFrom: BadHabit {

    init(name: String, id: String) {
        self.name = name
        self.identification = id
    }

    var name: String = ""
    var identification: String = ""
    var isSelected: Observable<Bool> {
        return  Observable.empty()
    }

    func select() {

    }
}
