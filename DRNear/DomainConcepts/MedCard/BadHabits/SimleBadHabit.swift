//
// Created by Артмеий Шлесберг on 06/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

class SimpleBadHabit: BadHabit {

    var name: String = "Курение"
    var identification: String = "123"
    var isSelected: Observable<Bool> {
        return Observable.just(true)
    }

    func select() {

    }

}
